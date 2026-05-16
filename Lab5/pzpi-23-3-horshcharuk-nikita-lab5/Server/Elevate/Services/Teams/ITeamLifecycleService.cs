using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamLifecycleService
{
    Task<TeamDetailDto> CreateMyTeamAsync(
        string name,
        string? description,
        int? maxMembers,
        int creatorUserId,
        CancellationToken cancellationToken);

    Task DeleteTeamAsync(int teamId, int userId, CancellationToken cancellationToken);

    Task<TeamDetailDto> UpdateTeamAsync(
        int teamId,
        UpdateTeamDto dto,
        int actingUserId,
        CancellationToken cancellationToken);
}
