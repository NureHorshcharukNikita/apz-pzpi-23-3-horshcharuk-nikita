using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamCatalogService
{
    Task<IReadOnlyCollection<TeamDto>> GetTeamsAsync(CancellationToken cancellationToken);
    Task<TeamDetailDto?> GetTeamAsync(int id, CancellationToken cancellationToken);
}
