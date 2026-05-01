namespace Elevate.Dtos.Users;

public class UserActivityItemDto
{
    public string Id { get; set; } = null!;
    public int TeamId { get; set; }
    public string TeamName { get; set; } = null!;
    public string Type { get; set; } = "points";
    public string Description { get; set; } = null!;
    public int Points { get; set; }
    public DateTime Date { get; set; }
}
