using Elevate.Data;
using Elevate.Entities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Gamification;

public class GamificationService : IGamificationService
{
    private readonly ElevateDbContext _dbContext;

    public GamificationService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyCollection<UserTeamBadge>> EvaluateBadgesAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        var membership = await GetMembershipAsync(teamId, userId, cancellationToken);
        if (membership is null)
        {
            return Array.Empty<UserTeamBadge>();
        }

        var allBadges = await GetTeamBadgesAsync(teamId, cancellationToken);
        var existingBadgeIds = await GetExistingBadgeIdsAsync(teamId, userId, cancellationToken);

        var rawLevels = await _dbContext.TeamLevels
            .Where(tl => tl.TeamID == teamId)
            .OrderBy(tl => tl.OrderIndex)
            .ToListAsync(cancellationToken);
        var (reachedLevelOrder, _, _, _, _) =
            TeamLevelProgressCalculator.Compute(membership.TeamPoints, rawLevels);

        var earnedBadges = new List<UserTeamBadge>();

        foreach (var badge in allBadges)
        {
            if (existingBadgeIds.Contains(badge.TeamBadgeID))
            {
                continue;
            }

            if (CanAwardBadge(badge, membership, reachedLevelOrder))
            {
                var userTeamBadge = CreateUserTeamBadge(badge, membership);
                earnedBadges.Add(userTeamBadge);
                _dbContext.UserTeamBadges.Add(userTeamBadge);
            }
        }

        if (earnedBadges.Count > 0)
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        return earnedBadges;
    }

    public async Task<int> AwardMissingBadgesForAllMembersAsync(
        int teamId,
        CancellationToken cancellationToken)
    {
        var userIds = await _dbContext.TeamMembers
            .Where(tm => tm.TeamID == teamId)
            .Select(tm => tm.UserID)
            .ToListAsync(cancellationToken);

        var total = 0;
        foreach (var userId in userIds)
        {
            var earned = await EvaluateBadgesAsync(teamId, userId, cancellationToken);
            total += earned.Count;
        }

        return total;
    }

    public async Task<TeamLevel?> UpdateMembershipLevelAsync(
        TeamMember membership,
        int teamId,
        CancellationToken cancellationToken)
    {
        var raw = await _dbContext.TeamLevels
            .Where(tl => tl.TeamID == teamId)
            .OrderBy(tl => tl.OrderIndex)
            .ToListAsync(cancellationToken);

        if (raw.Count == 0)
        {
            membership.TeamLevelID = null;
            return null;
        }

        var milestones = EffectiveTeamLevelMilestones.Build(raw);
        var byOrder = milestones.ToDictionary(m => m.OrderIndex);

        var mergedByOrder = raw
            .GroupBy(l => l.OrderIndex)
            .Select(g => g.OrderByDescending(x => x.RequiredPoints).First())
            .OrderByDescending(l => l.OrderIndex)
            .ToList();

        foreach (var row in mergedByOrder)
        {
            if (!byOrder.TryGetValue(row.OrderIndex, out var m))
                continue;
            if (membership.TeamPoints >= m.CumulativePoints)
            {
                membership.TeamLevelID = row.TeamLevelID;
                return row;
            }
        }

        membership.TeamLevelID = null;
        return null;
    }

    private Task<TeamMember?> GetMembershipAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken) =>
        _dbContext.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

    private Task<List<TeamBadge>> GetTeamBadgesAsync(
        int teamId,
        CancellationToken cancellationToken) =>
        _dbContext.TeamBadges
            .Where(tb => tb.TeamID == teamId)
            .ToListAsync(cancellationToken);

    private async Task<HashSet<int>> GetExistingBadgeIdsAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        var ids = await _dbContext.UserTeamBadges
            .Where(utb => utb.TeamID == teamId && utb.UserID == userId)
            .Select(utb => utb.TeamBadgeID)
            .ToListAsync(cancellationToken);

        return ids.ToHashSet();
    }

    private static bool CanAwardBadge(
        TeamBadge badge,
        TeamMember membership,
        int reachedLevelOrder)
    {
        if (!badge.ConditionValue.HasValue)
            return false;

        var v = badge.ConditionValue.Value;

        if (BadgeAwardRules.IsPointsCondition(badge.ConditionType))
            return membership.TeamPoints >= v;

        if (BadgeAwardRules.IsLevelOrderCondition(badge.ConditionType))
            return reachedLevelOrder >= v;

        return false;
    }

    private static UserTeamBadge CreateUserTeamBadge(TeamBadge badge, TeamMember membership)
    {
        return new UserTeamBadge
        {
            TeamBadgeID = badge.TeamBadgeID,
            TeamID = membership.TeamID,
            UserID = membership.UserID,
            TeamBadge = badge
        };
    }
}
