namespace Elevate.Dtos.Teams;

public class TeamMemberDto
{
    public int UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string TeamRole { get; set; } = null!;
    public int TeamPoints { get; set; }
    public int Level { get; set; }
    public string? TeamLevel { get; set; }
    public int CurrentXp { get; set; }
    public int NextLevelXp { get; set; }

    public bool AtMaxTier { get; set; }
}
