using Elevate.Dtos.Teams;
using Elevate.Entities;
using Elevate.Services.Gamification;

namespace Elevate.Mappings.Teams;

internal static class TeamMappings
{
    public static TeamMemberDto ToTeamMemberDto(
        TeamMember tm,
        IReadOnlyList<TeamLevel> levelsOrdered)
    {
        var (level, currentXp, nextLevelXp, tierName, atMaxTier) =
            TeamLevelProgressCalculator.Compute(tm.TeamPoints, levelsOrdered);

        return new TeamMemberDto
        {
            UserId = tm.UserID,
            FullName = $"{tm.User.FirstName} {tm.User.LastName}",
            TeamRole = tm.TeamRole,
            TeamPoints = tm.TeamPoints,
            Level = level,
            TeamLevel = tierName,
            CurrentXp = currentXp,
            NextLevelXp = nextLevelXp,
            AtMaxTier = atMaxTier
        };
    }

    public static TeamLevelDto ToTeamLevelDto(TeamLevel tl) => new()
    {
        Id = tl.TeamLevelID,
        Name = tl.Name,
        RequiredPoints = tl.RequiredPoints,
        OrderIndex = tl.OrderIndex
    };

    public static TeamBadgeDto ToTeamBadgeDto(TeamBadge tb) => new()
    {
        Id = tb.TeamBadgeID,
        Code = tb.Code,
        Name = tb.Name,
        Description = tb.Description,
        IconCode = tb.IconCode,
        ConditionType = tb.ConditionType,
        ConditionValue = tb.ConditionValue
    };

    public static LeaderboardEntryDto ToLeaderboardEntryDto(
        TeamMember tm,
        int rank,
        IReadOnlyList<TeamLevel> levelsOrdered)
    {
        var (level, currentXp, nextLevelXp, tierName, atMaxTier) =
            TeamLevelProgressCalculator.Compute(tm.TeamPoints, levelsOrdered);

        return new LeaderboardEntryDto
        {
            UserId = tm.UserID,
            FullName = $"{tm.User.FirstName} {tm.User.LastName}",
            TeamPoints = tm.TeamPoints,
            Level = level,
            TeamLevel = tierName,
            CurrentXp = currentXp,
            NextLevelXp = nextLevelXp,
            AtMaxTier = atMaxTier,
            Rank = rank
        };
    }
}
