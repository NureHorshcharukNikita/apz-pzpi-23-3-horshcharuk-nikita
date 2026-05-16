namespace Elevate.Dtos.Users;

public class TeamDashboardDto
{
    public int TeamId { get; set; }
    public string TeamName { get; set; } = null!;
    public int Level { get; set; }
    public int Points { get; set; }
    public int Rank { get; set; }
    public int CurrentXp { get; set; }
    public int NextLevelXp { get; set; }

    public bool AtMaxTier { get; set; }

    public string? TierName { get; set; }
    public IReadOnlyList<string> RecentAchievements { get; set; } = Array.Empty<string>();
}
