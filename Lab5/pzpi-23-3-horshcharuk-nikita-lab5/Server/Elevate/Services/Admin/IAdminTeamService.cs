using Elevate.Entities;

namespace Elevate.Services.Admin;

public interface IAdminTeamService
{
    Task<Team> CreateTeamAsync(
        string name,
        string? description,
        int? managerUserId,
        int? maxMembers,
        CancellationToken ct = default);

    Task UpdateTeamAsync(int teamId, string name, string? description, int? maxMembers, CancellationToken ct = default);
    Task SetLevelPointsModeAsync(int teamId, TeamLevelPointsMode mode, CancellationToken ct = default);
    Task DeleteTeamAsync(int teamId, CancellationToken ct = default);

    Task AddMemberAsync(int teamId, int userId, string teamRole, CancellationToken ct = default);
    Task RemoveMemberAsync(int teamId, int userId, CancellationToken ct = default);
    Task ChangeMemberRoleAsync(int teamId, int userId, string teamRole, CancellationToken ct = default);
}
