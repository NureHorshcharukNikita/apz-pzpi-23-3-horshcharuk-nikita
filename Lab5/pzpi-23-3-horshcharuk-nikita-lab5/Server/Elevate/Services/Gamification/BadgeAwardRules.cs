namespace Elevate.Services.Gamification;

public static class BadgeAwardRules
{
    public static bool IsPointsCondition(string? t)
    {
        if (string.IsNullOrWhiteSpace(t))
            return false;

        return t.Equals("TotalPoints", StringComparison.OrdinalIgnoreCase)
            || t.Equals("PointsReached", StringComparison.OrdinalIgnoreCase)
            || t.Equals("Points", StringComparison.OrdinalIgnoreCase)
            || t.Equals("XP", StringComparison.OrdinalIgnoreCase);
    }

    public static bool IsLevelOrderCondition(string? t)
    {
        if (string.IsNullOrWhiteSpace(t))
            return false;

        return t.Equals("TeamLevel", StringComparison.OrdinalIgnoreCase)
            || t.Equals("LevelOrder", StringComparison.OrdinalIgnoreCase);
    }

    public static bool IsRecognized(string? t) =>
        IsPointsCondition(t) || IsLevelOrderCondition(t);
}
