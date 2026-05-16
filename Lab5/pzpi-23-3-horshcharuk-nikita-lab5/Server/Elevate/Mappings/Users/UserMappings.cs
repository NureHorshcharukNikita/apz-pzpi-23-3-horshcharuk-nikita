using Elevate.Dtos.Users;
using Elevate.Entities;

namespace Elevate.Mappings.Users;

public static class UserMappings
{
    public static UserProfileDto ToUserProfileDto(User user) => new()
    {
        Id = user.UserID,
        Login = user.Login,
        FirstName = user.FirstName,
        LastName = user.LastName,
        Email = user.Email,
        Role = user.Role,
        IsActive = user.IsActive,
        CreatedAt = user.CreatedAt,
        LastLoginAt = user.LastLoginAt,
        AvatarUrl = user.Avatar == null ? null : "/api/users/avatar",
        Teams = user.TeamMemberships
            .Select(ToUserTeamMembershipDto)
            .OrderBy(t => t.TeamName)
            .ToArray(),
        RecentBadges = user.UserTeamBadges
            .OrderByDescending(utb => utb.AwardedAt)
            .Take(10)
            .Select(ToUserTeamBadgeDto)
            .ToArray()
    };

    public static UserTeamMembershipDto ToUserTeamMembershipDto(TeamMember tm) => new()
    {
        TeamId = tm.TeamID,
        TeamName = tm.Team.Name,
        TeamRole = tm.TeamRole,
        TeamPoints = tm.TeamPoints,
        Level = tm.TeamLevel?.OrderIndex,
        TeamLevel = tm.TeamLevel?.Name,
        CreatedByUserId = tm.Team.CreatedByUserID
    };

    public static UserTeamBadgeDto ToUserTeamBadgeDto(UserTeamBadge utb) => new()
    {
        TeamId = utb.TeamID,
        TeamName = utb.Team.Name,
        BadgeName = utb.TeamBadge.Name,
        AwardedAt = utb.AwardedAt
    };
}
