using Elevate.Data;
using Elevate.Entities;
using Elevate.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class AdminTeamService : IAdminTeamService
{
    private readonly ElevateDbContext _dbContext;

    public AdminTeamService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public async Task<Team> CreateTeamAsync(
        string name,
        string? description,
        int? managerUserId,
        int? maxMembers,
        CancellationToken ct = default)
    {
        if (maxMembers is < 1)
        {
            throw new ClientErrorException("admin.apiErrorTeamMaxMembersCreate");
        }

        var teamName = name.Trim();
        if (string.IsNullOrWhiteSpace(teamName))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        var team = new Team
        {
            Name = teamName,
            Description = description,
            CreatedAt = DateTime.UtcNow,
            CreatedByUserID = managerUserId,
            MaxMembers = maxMembers,
        };

        _dbContext.Teams.Add(team);
        await _dbContext.SaveChangesAsync(ct);

        if (managerUserId.HasValue)
        {
            var member = new TeamMember
            {
                TeamID = team.TeamID,
                UserID = managerUserId.Value,
                TeamRole = "Lead",
                JoinedAt = DateTime.UtcNow,
                TeamPoints = 0
            };
            _dbContext.TeamMembers.Add(member);

            var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserID == managerUserId.Value, ct);
            if (user != null && user.Role == "User")
            {
                user.Role = "Manager";
            }

            await _dbContext.SaveChangesAsync(ct);
        }

        return team;
    }

    public async Task UpdateTeamAsync(
        int teamId,
        string name,
        string? description,
        int? maxMembers,
        CancellationToken ct = default)
    {
        var team = await _dbContext.Teams.FirstOrDefaultAsync(t => t.TeamID == teamId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorTeamNotFound");

        if (maxMembers is < 1)
        {
            throw new ClientErrorException("admin.apiErrorTeamMaxMembersUpdate");
        }

        if (maxMembers is int cap)
        {
            var count = await _dbContext.TeamMembers.CountAsync(tm => tm.TeamID == teamId, ct);
            if (cap < count)
            {
                throw new ClientErrorException(
                    "admin.apiErrorTeamMaxBelowMemberCount",
                    new Dictionary<string, string> { ["count"] = count.ToString() });
            }
        }

        var teamName = name.Trim();
        if (string.IsNullOrWhiteSpace(teamName))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        team.Name = teamName;
        team.Description = description;
        team.MaxMembers = maxMembers;

        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task SetLevelPointsModeAsync(int teamId, TeamLevelPointsMode mode, CancellationToken ct = default)
    {
        if (mode is not (TeamLevelPointsMode.RelativeSegments or TeamLevelPointsMode.AbsoluteTotals))
        {
            throw new ClientErrorException("admin.apiErrorInvalidLevelPointsMode");
        }

        var team = await _dbContext.Teams.FirstOrDefaultAsync(t => t.TeamID == teamId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorTeamNotFound");

        team.LevelPointsMode = mode;
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task DeleteTeamAsync(int teamId, CancellationToken ct = default)
    {
        var team = await _dbContext.Teams.FirstOrDefaultAsync(t => t.TeamID == teamId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorTeamNotFound");

        _dbContext.Teams.Remove(team);
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task AddMemberAsync(int teamId, int userId, string teamRole, CancellationToken ct = default)
    {
        var exists = await _dbContext.TeamMembers
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == userId, ct);

        if (exists) return;

        var cap = await _dbContext.Teams
            .AsNoTracking()
            .Where(t => t.TeamID == teamId)
            .Select(t => t.MaxMembers)
            .FirstOrDefaultAsync(ct);

        if (cap is int maxMembers)
        {
            var count = await _dbContext.TeamMembers.CountAsync(tm => tm.TeamID == teamId, ct);
            if (count >= maxMembers)
            {
                throw new ClientErrorException(
                    "admin.apiErrorTeamFull",
                    new Dictionary<string, string>
                    {
                        ["current"] = count.ToString(),
                        ["max"] = maxMembers.ToString(),
                    });
            }
        }

        var staleJoinRequests = await _dbContext.TeamJoinRequests
            .Where(r => r.TeamID == teamId && r.UserID == userId)
            .ToListAsync(ct);
        _dbContext.TeamJoinRequests.RemoveRange(staleJoinRequests);

        var member = new TeamMember
        {
            TeamID = teamId,
            UserID = userId,
            TeamRole = teamRole,
            JoinedAt = DateTime.UtcNow,
            TeamPoints = 0
        };

        _dbContext.TeamMembers.Add(member);
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task RemoveMemberAsync(int teamId, int userId, CancellationToken ct = default)
    {
        var member = await _dbContext.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, ct)
            ?? throw new ClientErrorException("admin.apiErrorTeamMemberNotFound");

        var joinRequests = await _dbContext.TeamJoinRequests
            .Where(r => r.TeamID == teamId && r.UserID == userId)
            .ToListAsync(ct);
        _dbContext.TeamJoinRequests.RemoveRange(joinRequests);

        _dbContext.TeamMembers.Remove(member);
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task ChangeMemberRoleAsync(int teamId, int userId, string teamRole, CancellationToken ct = default)
    {
        var member = await _dbContext.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, ct)
            ?? throw new ClientErrorException("admin.apiErrorTeamMemberNotFound");

        member.TeamRole = teamRole;
        await _dbContext.SaveChangesAsync(ct);
    }
}
