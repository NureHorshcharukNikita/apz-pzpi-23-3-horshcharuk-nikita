using Elevate.Entities;

namespace Elevate.Dtos.Teams;

public class UpdateTeamDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }

    public TeamLevelPointsMode? LevelPointsMode { get; set; }

    public bool UpdateMaxMembers { get; set; }

    public int? MaxMembers { get; set; }
}
