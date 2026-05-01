using Elevate.Data;
using Elevate.Dtos.Teams;
using Elevate.Mappings.Teams;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamRosterService : ITeamRosterService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;
    private readonly IGamificationService _gamification;

    public TeamRosterService(
        ElevateDbContext dbContext,
        TeamServiceShared shared,
        IGamificationService gamification)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
        _gamification = gamification ?? throw new ArgumentNullException(nameof(gamification));
    }

    public async Task<IReadOnlyCollection<TeamMemberDto>> GetMembersAsync(
        int teamId,
        CancellationToken cancellationToken)
    {
        var levels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(cancellationToken);

        var members = await _dbContext.TeamMembers
            .AsNoTracking()
            .Where(tm => tm.TeamID == teamId)
            .Include(tm => tm.User)
            .OrderByDescending(tm => tm.TeamPoints)
            .ToListAsync(cancellationToken);

        return members
            .Select(tm => TeamMappings.ToTeamMemberDto(tm, levels))
            .ToArray();
    }

    public async Task<IReadOnlyCollection<LeaderboardEntryDto>> GetLeaderboardAsync(
        int teamId,
        CancellationToken cancellationToken,
        int top = 10)
    {
        var levels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(cancellationToken);

        var members = await _dbContext.TeamMembers
            .AsNoTracking()
            .Where(tm => tm.TeamID == teamId)
            .Include(tm => tm.User)
            .OrderByDescending(tm => tm.TeamPoints)
            .Take(top)
            .ToListAsync(cancellationToken);

        return members
            .Select((tm, index) => TeamMappings.ToLeaderboardEntryDto(tm, index + 1, levels))
            .ToArray();
    }

    public async Task<TeamMemberDto> SetMemberTeamPointsAsync(
        int teamId,
        int memberUserId,
        int teamPoints,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        if (teamPoints < 0)
        {
            throw new InvalidOperationException("Team points cannot be negative.");
        }

        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var membership = await _dbContext.TeamMembers
            .Include(tm => tm.User)
            .FirstOrDefaultAsync(
                tm => tm.TeamID == teamId && tm.UserID == memberUserId,
                cancellationToken);

        if (membership is null)
        {
            throw new InvalidOperationException("User is not a member of this team.");
        }

        membership.TeamPoints = teamPoints;
        await _gamification.UpdateMembershipLevelAsync(membership, teamId, cancellationToken);
        await _dbContext.SaveChangesAsync(cancellationToken);
        await _gamification.EvaluateBadgesAsync(teamId, memberUserId, cancellationToken);

        var levels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(cancellationToken);

        var fresh = await _dbContext.TeamMembers
            .AsNoTracking()
            .Include(tm => tm.User)
            .FirstAsync(tm => tm.TeamID == teamId && tm.UserID == memberUserId, cancellationToken);

        return TeamMappings.ToTeamMemberDto(fresh, levels);
    }

    public async Task LeaveTeamAsync(int teamId, int userId, CancellationToken cancellationToken)
    {
        var team = await _dbContext.Teams
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken);

        if (team?.CreatedByUserID == userId)
        {
            throw new InvalidOperationException(
                "Team creators cannot leave the team. Delete the team or ask an administrator for help.");
        }

        var member = await _dbContext.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        if (member is null)
        {
            throw new InvalidOperationException("You are not a member of this team.");
        }

        await _shared.RemoveMemberDataAsync(teamId, userId, cancellationToken);
    }

    public async Task RemoveTeamMemberAsync(
        int teamId,
        int targetUserId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        var team = await _dbContext.Teams
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken);

        if (team is null)
        {
            throw new InvalidOperationException($"Team with id {teamId} not found.");
        }

        if (!await _shared.IsGlobalAdminOrManagerAsync(actingUserId, cancellationToken)
            && team.CreatedByUserID != actingUserId)
        {
            throw new UnauthorizedAccessException(
                "Only the team creator or an administrator can remove members.");
        }

        if (team.CreatedByUserID == targetUserId)
        {
            throw new InvalidOperationException("Cannot remove the team creator from the team.");
        }

        await _shared.RemoveMemberDataAsync(teamId, targetUserId, cancellationToken);
    }
}
