using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamRosterService
{
    Task<IReadOnlyCollection<TeamMemberDto>> GetMembersAsync(int teamId, CancellationToken cancellationToken);
    Task<IReadOnlyCollection<LeaderboardEntryDto>> GetLeaderboardAsync(
        int teamId,
        CancellationToken cancellationToken,
        int top = 10);

    Task<TeamMemberDto> SetMemberTeamPointsAsync(
        int teamId,
        int memberUserId,
        int teamPoints,
        int actingUserId,
        CancellationToken cancellationToken);

    Task LeaveTeamAsync(int teamId, int userId, CancellationToken cancellationToken);

    Task RemoveTeamMemberAsync(
        int teamId,
        int targetUserId,
        int actingUserId,
        CancellationToken cancellationToken);
}
