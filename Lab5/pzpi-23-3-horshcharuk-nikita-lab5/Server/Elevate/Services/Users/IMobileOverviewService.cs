using System.Security.Claims;
using Elevate.Dtos.Users;

namespace Elevate.Services.Users;

public interface IMobileOverviewService
{
    Task<IReadOnlyList<TeamDashboardDto>> GetMyTeamDashboardsAsync(
        ClaimsPrincipal user,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<UserActivityItemDto>> GetMyActivityAsync(
        ClaimsPrincipal user,
        int? teamId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<UserAchievementItemDto>> GetMyAchievementsAsync(
        ClaimsPrincipal user,
        CancellationToken cancellationToken);
}
