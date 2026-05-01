namespace Elevate.Dtos.Teams;

public class MyPendingJoinRequestDto
{
    public int Id { get; set; }
    public int TeamId { get; set; }
    public string TeamName { get; set; } = null!;
    public string Status { get; set; } = null!;
    public DateTime RequestedAt { get; set; }
}
