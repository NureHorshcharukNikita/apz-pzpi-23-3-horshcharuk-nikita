using Elevate.Entities;

namespace Elevate.Dtos.Admin.Gamification.Levels;

public class TeamLevelsForAdminDto
{
    public IReadOnlyList<TeamLevel> Levels { get; set; } = Array.Empty<TeamLevel>();

    public int LevelPointsMode { get; set; }
}
