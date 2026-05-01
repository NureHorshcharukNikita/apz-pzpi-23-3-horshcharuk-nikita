using System.Security.Claims;
using Elevate.Data;
using Elevate.Dtos.Users;
using Elevate.Entities;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Users;

public class MobileOverviewService : IMobileOverviewService
{
    private readonly ElevateDbContext _dbContext;

    public MobileOverviewService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<TeamDashboardDto>> GetMyTeamDashboardsAsync(
        ClaimsPrincipal user,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId(user);
        if (userId is null)
            return Array.Empty<TeamDashboardDto>();

        var memberships = await _dbContext.TeamMembers
            .AsNoTracking()
            .Where(tm => tm.UserID == userId.Value)
            .Include(tm => tm.Team)
            .ToListAsync(cancellationToken);

        if (memberships.Count == 0)
            return Array.Empty<TeamDashboardDto>();

        var teamIds = memberships.Select(m => m.TeamID).Distinct().ToList();

        var allLevels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(l => teamIds.Contains(l.TeamID))
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(cancellationToken);

        var levelsByTeam = allLevels
            .GroupBy(l => l.TeamID)
            .ToDictionary(g => g.Key, g => g.ToList());

        var results = new List<TeamDashboardDto>(memberships.Count);

        foreach (var m in memberships)
        {
            var teamName = m.Team?.Name ?? "Team";
            var levels = levelsByTeam.GetValueOrDefault(m.TeamID) ?? new List<TeamLevel>();

            var rank = await _dbContext.TeamMembers
                .AsNoTracking()
                .CountAsync(
                    tm => tm.TeamID == m.TeamID && tm.TeamPoints > m.TeamPoints,
                    cancellationToken) + 1;

            var (level, currentXp, nextLevelXp, tierName, atMaxTier) =
                TeamLevelProgressCalculator.Compute(m.TeamPoints, levels);

            var recentBadges = await _dbContext.UserTeamBadges
                .AsNoTracking()
                .Where(utb => utb.UserID == userId.Value && utb.TeamID == m.TeamID)
                .Include(utb => utb.TeamBadge)
                .OrderByDescending(utb => utb.AwardedAt)
                .Take(5)
                .Select(utb => utb.TeamBadge.Name)
                .ToListAsync(cancellationToken);

            results.Add(new TeamDashboardDto
            {
                TeamId = m.TeamID,
                TeamName = teamName,
                Level = level,
                Points = m.TeamPoints,
                Rank = rank,
                CurrentXp = currentXp,
                NextLevelXp = nextLevelXp,
                AtMaxTier = atMaxTier,
                TierName = tierName,
                RecentAchievements = recentBadges
            });
        }

        return results.OrderBy(r => r.TeamName).ToList();
    }

    public async Task<IReadOnlyList<UserActivityItemDto>> GetMyActivityAsync(
        ClaimsPrincipal user,
        int? teamId,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId(user);
        if (userId is null)
            return Array.Empty<UserActivityItemDto>();

        var baseQuery = _dbContext.ActionEvents
            .AsNoTracking()
            .Where(ae => ae.UserID == userId.Value && ae.IsValid);

        if (teamId.HasValue)
            baseQuery = baseQuery.Where(ae => ae.TeamID == teamId.Value);

        var rows = await baseQuery
            .OrderByDescending(ae => ae.OccurredAt)
            .Take(50)
            .Join(
                _dbContext.Teams.AsNoTracking(),
                ae => ae.TeamID,
                t => t.TeamID,
                (ae, t) => new { ae, TeamName = t.Name })
            .Join(
                _dbContext.ActionTypes.AsNoTracking(),
                x => x.ae.ActionTypeID,
                at => at.ActionTypeID,
                (x, at) => new { x.ae, x.TeamName, ActionName = at.Name })
            .ToListAsync(cancellationToken);

        return rows.Select(x => new UserActivityItemDto
        {
            Id = x.ae.ActionEventID.ToString(),
            TeamId = x.ae.TeamID,
            TeamName = x.TeamName,
            Type = "points",
            Description = x.ActionName,
            Points = x.ae.PointsAwarded,
            Date = x.ae.OccurredAt
        }).ToList();
    }

    public async Task<IReadOnlyList<UserAchievementItemDto>> GetMyAchievementsAsync(
        ClaimsPrincipal user,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId(user);
        if (userId is null)
            return Array.Empty<UserAchievementItemDto>();

        var rows = await _dbContext.UserTeamBadges
            .AsNoTracking()
            .Where(utb => utb.UserID == userId.Value)
            .Include(utb => utb.TeamBadge)
            .Include(utb => utb.Team)
            .OrderByDescending(utb => utb.AwardedAt)
            .ToListAsync(cancellationToken);

        return rows
            .Select(utb => new UserAchievementItemDto
            {
                Id = utb.UserTeamBadgeID.ToString(),
                Title = utb.TeamBadge.Name,
                Description = utb.TeamBadge.Description ?? string.Empty,
                Earned = true,
                EarnedAt = utb.AwardedAt,
                TeamId = utb.TeamID,
                TeamName = utb.Team.Name,
                Requirement = FormatBadgeRequirement(utb.TeamBadge)
            })
            .ToArray();
    }

    private static string? FormatBadgeRequirement(TeamBadge badge)
    {
        if (badge.ConditionValue is null)
            return null;

        var v = badge.ConditionValue.Value;
        if (BadgeAwardRules.IsPointsCondition(badge.ConditionType))
            return $"Reach {v} team XP";
        if (BadgeAwardRules.IsLevelOrderCondition(badge.ConditionType))
            return $"Reach level {v}";
        if (!string.IsNullOrWhiteSpace(badge.ConditionType))
            return $"{badge.ConditionType}: {v}";
        return null;
    }

    private static int? GetUserId(ClaimsPrincipal user)
    {
        var idClaim = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(idClaim, out var id) ? id : null;
    }

}
