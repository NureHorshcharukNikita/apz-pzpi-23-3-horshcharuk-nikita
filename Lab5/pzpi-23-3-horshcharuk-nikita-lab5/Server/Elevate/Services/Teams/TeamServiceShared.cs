using Elevate.Data;
using Elevate.Entities;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamServiceShared
{
    private readonly ElevateDbContext _dbContext;

    public TeamServiceShared(ElevateDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public IQueryable<Team> GetTeamWithDetailsQuery() =>
        _dbContext.Teams
            .AsNoTracking()
            .Include(t => t.Members)
            .ThenInclude(tm => tm.User)
            .Include(t => t.Levels)
            .Include(t => t.Badges);

    public Task<bool> TeamExistsAsync(int teamId, CancellationToken cancellationToken) =>
        _dbContext.Teams
            .AsNoTracking()
            .AnyAsync(t => t.TeamID == teamId, cancellationToken);

    public async Task EnsureTeamExistsAsync(int teamId, CancellationToken cancellationToken)
    {
        if (!await TeamExistsAsync(teamId, cancellationToken))
        {
            throw new InvalidOperationException($"Team with id {teamId} not found.");
        }
    }

    public async Task EnsureTeamHasCapacityForNewMemberAsync(
        int teamId,
        CancellationToken cancellationToken)
    {
        var cap = await _dbContext.Teams
            .AsNoTracking()
            .Where(t => t.TeamID == teamId)
            .Select(t => t.MaxMembers)
            .FirstOrDefaultAsync(cancellationToken);

        if (cap is null)
        {
            return;
        }

        var count = await _dbContext.TeamMembers
            .CountAsync(tm => tm.TeamID == teamId, cancellationToken);

        if (count >= cap.Value)
        {
            throw new InvalidOperationException("This team is full.");
        }
    }

    public async Task EnsureTeamLevelOrderUniqueAsync(
        int teamId,
        int orderIndex,
        int? exceptLevelId,
        CancellationToken cancellationToken)
    {
        var taken = await _dbContext.TeamLevels
            .AsNoTracking()
            .AnyAsync(
                l => l.TeamID == teamId
                    && l.OrderIndex == orderIndex
                    && (exceptLevelId == null || l.TeamLevelID != exceptLevelId),
                cancellationToken);

        if (taken)
        {
            throw new InvalidOperationException(
                $"This team already has a level with number {orderIndex}. Edit or delete it first.");
        }
    }

    public async Task AddTeamMemberCoreAsync(int teamId, int userId, CancellationToken cancellationToken)
    {
        var firstLevel = await _dbContext.TeamLevels
            .Where(tl => tl.TeamID == teamId)
            .OrderBy(tl => tl.OrderIndex)
            .FirstOrDefaultAsync(cancellationToken);

        var member = new TeamMember
        {
            TeamID = teamId,
            UserID = userId,
            TeamRole = "Member",
            JoinedAt = DateTime.UtcNow,
            TeamPoints = 0,
            TeamLevelID = firstLevel?.TeamLevelID
        };

        _dbContext.TeamMembers.Add(member);
    }

    public async Task RemoveMemberDataAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        var member = await _dbContext.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        if (member is null)
        {
            throw new InvalidOperationException("User is not a member of this team.");
        }

        await using var transaction =
            await _dbContext.Database.BeginTransactionAsync(cancellationToken);

        var badgeRows = await _dbContext.UserTeamBadges
            .Where(utb => utb.UserID == userId && utb.TeamID == teamId)
            .ToListAsync(cancellationToken);
        _dbContext.UserTeamBadges.RemoveRange(badgeRows);

        var scanRows = await _dbContext.DeviceScans
            .Where(ds => ds.UserID == userId && ds.TeamID == teamId)
            .ToListAsync(cancellationToken);
        _dbContext.DeviceScans.RemoveRange(scanRows);

        var eventRows = await _dbContext.ActionEvents
            .Where(ae =>
                ae.TeamID == teamId &&
                (ae.UserID == userId || ae.SourceUserID == userId))
            .ToListAsync(cancellationToken);
        _dbContext.ActionEvents.RemoveRange(eventRows);

        var joinRequestRows = await _dbContext.TeamJoinRequests
            .Where(r => r.TeamID == teamId && r.UserID == userId)
            .ToListAsync(cancellationToken);
        _dbContext.TeamJoinRequests.RemoveRange(joinRequestRows);

        _dbContext.TeamMembers.Remove(member);
        await _dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
    }

    public async Task<bool> CanManageJoinRequestsAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.UserID == userId, cancellationToken);

        if (user is null)
        {
            return false;
        }

        if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)
            || string.Equals(user.Role, "Manager", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        var team = await _dbContext.Teams
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken);

        if (team?.CreatedByUserID == userId)
        {
            return true;
        }

        var membership = await _dbContext.TeamMembers
            .AsNoTracking()
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        return membership is not null
               && string.Equals(membership.TeamRole, "Lead", StringComparison.OrdinalIgnoreCase);
    }

    public async Task EnsureCanManageTeamGamificationAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        await EnsureTeamExistsAsync(teamId, cancellationToken);

        if (await IsGlobalAdminOrManagerAsync(userId, cancellationToken))
        {
            return;
        }

        var team = await _dbContext.Teams
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken);

        if (team?.CreatedByUserID == userId)
        {
            return;
        }

        var membership = await _dbContext.TeamMembers
            .AsNoTracking()
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        if (membership is not null
            && string.Equals(membership.TeamRole, "Lead", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        throw new UnauthorizedAccessException(
            "Only the team creator, a team lead, or an administrator can manage gamification.");
    }

    public async Task<bool> CanDeleteTeamAsync(
        Team team,
        int userId,
        CancellationToken cancellationToken)
    {
        if (await IsGlobalAdminOrManagerAsync(userId, cancellationToken))
        {
            return true;
        }

        return team.CreatedByUserID == userId;
    }

    public async Task<bool> IsGlobalAdminOrManagerAsync(int userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.UserID == userId, cancellationToken);

        if (user is null)
        {
            return false;
        }

        return string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)
               || string.Equals(user.Role, "Manager", StringComparison.OrdinalIgnoreCase);
    }

    public static void ValidateBadgeAwardCondition(string? conditionType, int? conditionValue)
    {
        if (!conditionValue.HasValue)
        {
            throw new InvalidOperationException(
                "Badge needs an award rule: set a team XP threshold or a target level order (same numbering as in Levels).");
        }

        if (string.IsNullOrWhiteSpace(conditionType)
            || !BadgeAwardRules.IsRecognized(conditionType))
        {
            throw new InvalidOperationException(
                "Unknown badge condition. Use a team XP threshold (TotalPoints) or level order (LevelOrder).");
        }

        if (BadgeAwardRules.IsPointsCondition(conditionType))
        {
            if (conditionValue.Value < 0)
            {
                throw new InvalidOperationException("Team XP threshold cannot be negative.");
            }

            return;
        }

        if (conditionValue.Value < 1)
        {
            throw new InvalidOperationException("Level order must be at least 1.");
        }
    }
}
