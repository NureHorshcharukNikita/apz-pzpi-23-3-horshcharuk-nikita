namespace Elevate.Dtos.Users;

public class UserAchievementItemDto
{
    public string Id { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public bool Earned { get; set; } = true;
    public DateTime? EarnedAt { get; set; }
    public int TeamId { get; set; }
    public string TeamName { get; set; } = null!;
    public string? Requirement { get; set; }
}
