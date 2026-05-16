using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public interface ITeamGamificationSetupService
{
    Task<TeamLevelDto> CreateLevelAsync(
        int teamId,
        CreateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<TeamBadgeDto> CreateBadgeAsync(
        int teamId,
        CreateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<TeamLevelDto> UpdateLevelAsync(
        int teamId,
        int levelId,
        UpdateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<TeamBadgeDto> UpdateBadgeAsync(
        int teamId,
        int badgeId,
        UpdateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task DeleteLevelAsync(
        int teamId,
        int levelId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task DeleteBadgeAsync(
        int teamId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<ActionTypeDto> CreateActionTypeAsync(
        int teamId,
        CreateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForGamificationSetupAsync(
        int teamId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<ActionTypeDto> UpdateActionTypeAsync(
        int teamId,
        int actionTypeId,
        UpdateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken);

    Task DeleteActionTypeAsync(
        int teamId,
        int actionTypeId,
        int actingUserId,
        CancellationToken cancellationToken);

    Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForMemberAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken);
}
