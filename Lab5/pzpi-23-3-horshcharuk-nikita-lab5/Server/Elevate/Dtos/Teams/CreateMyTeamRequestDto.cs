namespace Elevate.Dtos.Teams;

public class CreateMyTeamRequestDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }

    public int? MaxMembers { get; set; }
}
