namespace Elevate.Entities;

public class TeamJoinRequest
{
    public int TeamJoinRequestID { get; set; }
    public int TeamID { get; set; }
    public int UserID { get; set; }

    public string Status { get; set; } = "Pending";

    public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ProcessedAt { get; set; }
    public int? ProcessedByUserID { get; set; }

    public Team Team { get; set; } = null!;
    public User User { get; set; } = null!;
}
