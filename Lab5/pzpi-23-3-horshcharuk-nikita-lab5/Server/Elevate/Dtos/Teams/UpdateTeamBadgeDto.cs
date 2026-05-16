namespace Elevate.Dtos.Teams;

public class UpdateTeamBadgeDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public string? IconCode { get; set; }
    public string? ConditionType { get; set; }
    public int? ConditionValue { get; set; }
}
