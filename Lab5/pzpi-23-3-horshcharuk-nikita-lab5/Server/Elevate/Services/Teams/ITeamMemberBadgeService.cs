using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamMemberBadgeService
{
    Task<IReadOnlyList<MemberBadgeAwardDto>> GetMemberBadgeAwardsAsync(
        int teamId,
        int memberUserId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<MemberBadgeAwardDto> GrantMemberBadgeAsync(
        int teamId,
        int memberUserId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task RevokeMemberBadgeAwardAsync(
        int teamId,
        int memberUserId,
        int userTeamBadgeId,
        int actingUserId,
        CancellationToken cancellationToken);
}
