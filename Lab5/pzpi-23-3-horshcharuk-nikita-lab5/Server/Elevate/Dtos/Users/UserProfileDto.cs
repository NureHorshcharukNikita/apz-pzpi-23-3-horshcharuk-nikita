namespace Elevate.Dtos.Users;

public class UserProfileDto
{
    public int Id { get; set; }
    public string Login { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Role { get; set; } = null!;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public string? AvatarUrl { get; set; }
    public IReadOnlyCollection<UserTeamMembershipDto> Teams { get; set; } = Array.Empty<UserTeamMembershipDto>();
    public IReadOnlyCollection<UserTeamBadgeDto> RecentBadges { get; set; } = Array.Empty<UserTeamBadgeDto>();
}
