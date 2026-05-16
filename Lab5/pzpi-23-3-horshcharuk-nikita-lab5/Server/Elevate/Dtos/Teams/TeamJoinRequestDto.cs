namespace Elevate.Dtos.Teams;

public class TeamJoinRequestDto
{
    public int Id { get; set; }
    public int TeamId { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string Status { get; set; } = null!;
    public DateTime RequestedAt { get; set; }
}
