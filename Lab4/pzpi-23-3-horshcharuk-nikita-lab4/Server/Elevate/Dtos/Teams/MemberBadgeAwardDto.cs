namespace Elevate.Dtos.Teams;

public class MemberBadgeAwardDto
{
    public int UserTeamBadgeId { get; set; }
    public int TeamBadgeId { get; set; }
    public string BadgeName { get; set; } = string.Empty;
    public DateTime AwardedAt { get; set; }
}
