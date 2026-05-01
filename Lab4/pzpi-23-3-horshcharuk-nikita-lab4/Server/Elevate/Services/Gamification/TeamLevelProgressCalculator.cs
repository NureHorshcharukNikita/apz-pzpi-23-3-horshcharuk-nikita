using Elevate.Entities;

namespace Elevate.Services.Gamification;

public static class TeamLevelProgressCalculator
{
    public static (int Level, int CurrentXp, int NextLevelXp, string? TierName, bool AtMaxTier) Compute(
        int teamPoints,
        IReadOnlyList<TeamLevel> levelsOrdered)
    {
        var milestones = EffectiveTeamLevelMilestones.Build(levelsOrdered);
        if (milestones.Count == 0)
            return (0, 0, 0, null, false);

        var list = milestones.ToList();
        var currentIdx = -1;
        for (var i = 0; i < list.Count; i++)
        {
            if (teamPoints >= list[i].CumulativePoints)
                currentIdx = i;
            else
                break;
        }

        if (currentIdx < 0)
        {
            var first = list[0];
            var need = first.CumulativePoints;
            return (
                0,
                teamPoints,
                need > 0 ? need : 1,
                null,
                false);
        }

        var current = list[currentIdx];
        var tierName = TierNameVisible(teamPoints, current.AnchorName);

        if (currentIdx + 1 >= list.Count)
        {
            var overflow = Math.Max(0, teamPoints - current.CumulativePoints);
            return (
                current.OrderIndex,
                overflow,
                0,
                tierName,
                true);
        }

        var next = list[currentIdx + 1];
        var currentXp = Math.Max(0, teamPoints - current.CumulativePoints);
        var span = Math.Max(1, next.CumulativePoints - current.CumulativePoints);
        return (current.OrderIndex, currentXp, span, tierName, false);
    }

    public static string? TierNameVisible(int teamPoints, string? anchorName)
    {
        if (teamPoints <= 0 || string.IsNullOrWhiteSpace(anchorName))
            return null;
        return anchorName;
    }
}
