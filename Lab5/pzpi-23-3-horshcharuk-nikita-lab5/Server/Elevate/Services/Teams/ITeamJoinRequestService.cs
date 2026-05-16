using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamJoinRequestService
{
    Task RequestJoinTeamAsync(int teamId, int userId, CancellationToken cancellationToken);

    Task<IReadOnlyList<MyPendingJoinRequestDto>> GetMyPendingJoinRequestsAsync(
        int userId,
        CancellationToken cancellationToken);

    Task CancelMyJoinRequestAsync(int teamId, int userId, CancellationToken cancellationToken);

    Task<IReadOnlyList<TeamJoinRequestDto>> GetPendingJoinRequestsAsync(
        int teamId,
        int managerUserId,
        CancellationToken cancellationToken);

    Task ApproveJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken);

    Task RejectJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken);
}
