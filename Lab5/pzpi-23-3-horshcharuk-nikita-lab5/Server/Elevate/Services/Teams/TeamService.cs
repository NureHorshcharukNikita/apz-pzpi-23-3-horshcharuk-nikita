using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;

namespace Elevate.Services.Teams;

public sealed class TeamService : ITeamService
{
    private readonly ITeamCatalogService _catalog;
    private readonly ITeamLifecycleService _lifecycle;
    private readonly ITeamRosterService _roster;
    private readonly ITeamMemberBadgeService _memberBadges;
    private readonly ITeamGamificationSetupService _gamificationSetup;
    private readonly ITeamJoinRequestService _joinRequests;

    public TeamService(
        ITeamCatalogService catalog,
        ITeamLifecycleService lifecycle,
        ITeamRosterService roster,
        ITeamMemberBadgeService memberBadges,
        ITeamGamificationSetupService gamificationSetup,
        ITeamJoinRequestService joinRequests)
    {
        _catalog = catalog ?? throw new ArgumentNullException(nameof(catalog));
        _lifecycle = lifecycle ?? throw new ArgumentNullException(nameof(lifecycle));
        _roster = roster ?? throw new ArgumentNullException(nameof(roster));
        _memberBadges = memberBadges ?? throw new ArgumentNullException(nameof(memberBadges));
        _gamificationSetup = gamificationSetup ?? throw new ArgumentNullException(nameof(gamificationSetup));
        _joinRequests = joinRequests ?? throw new ArgumentNullException(nameof(joinRequests));
    }

    public Task<IReadOnlyCollection<TeamDto>> GetTeamsAsync(CancellationToken cancellationToken) =>
        _catalog.GetTeamsAsync(cancellationToken);

    public Task<TeamDetailDto?> GetTeamAsync(int id, CancellationToken cancellationToken) =>
        _catalog.GetTeamAsync(id, cancellationToken);

    public Task<TeamDetailDto> CreateMyTeamAsync(
        string name,
        string? description,
        int? maxMembers,
        int creatorUserId,
        CancellationToken cancellationToken) =>
        _lifecycle.CreateMyTeamAsync(name, description, maxMembers, creatorUserId, cancellationToken);

    public Task DeleteTeamAsync(int teamId, int userId, CancellationToken cancellationToken) =>
        _lifecycle.DeleteTeamAsync(teamId, userId, cancellationToken);

    public Task<TeamDetailDto> UpdateTeamAsync(
        int teamId,
        UpdateTeamDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _lifecycle.UpdateTeamAsync(teamId, dto, actingUserId, cancellationToken);

    public Task<IReadOnlyCollection<TeamMemberDto>> GetMembersAsync(
        int teamId,
        CancellationToken cancellationToken) =>
        _roster.GetMembersAsync(teamId, cancellationToken);

    public Task<IReadOnlyCollection<LeaderboardEntryDto>> GetLeaderboardAsync(
        int teamId,
        CancellationToken cancellationToken,
        int top = 10) =>
        _roster.GetLeaderboardAsync(teamId, cancellationToken, top);

    public Task<TeamMemberDto> SetMemberTeamPointsAsync(
        int teamId,
        int memberUserId,
        int teamPoints,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _roster.SetMemberTeamPointsAsync(teamId, memberUserId, teamPoints, actingUserId, cancellationToken);

    public Task<IReadOnlyList<MemberBadgeAwardDto>> GetMemberBadgeAwardsAsync(
        int teamId,
        int memberUserId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _memberBadges.GetMemberBadgeAwardsAsync(teamId, memberUserId, actingUserId, cancellationToken);

    public Task<MemberBadgeAwardDto> GrantMemberBadgeAsync(
        int teamId,
        int memberUserId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _memberBadges.GrantMemberBadgeAsync(teamId, memberUserId, badgeId, actingUserId, cancellationToken);

    public Task RevokeMemberBadgeAwardAsync(
        int teamId,
        int memberUserId,
        int userTeamBadgeId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _memberBadges.RevokeMemberBadgeAwardAsync(
            teamId,
            memberUserId,
            userTeamBadgeId,
            actingUserId,
            cancellationToken);

    public Task<TeamLevelDto> CreateLevelAsync(
        int teamId,
        CreateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.CreateLevelAsync(teamId, dto, actingUserId, cancellationToken);

    public Task<TeamBadgeDto> CreateBadgeAsync(
        int teamId,
        CreateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.CreateBadgeAsync(teamId, dto, actingUserId, cancellationToken);

    public Task<TeamLevelDto> UpdateLevelAsync(
        int teamId,
        int levelId,
        UpdateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.UpdateLevelAsync(teamId, levelId, dto, actingUserId, cancellationToken);

    public Task<TeamBadgeDto> UpdateBadgeAsync(
        int teamId,
        int badgeId,
        UpdateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.UpdateBadgeAsync(teamId, badgeId, dto, actingUserId, cancellationToken);

    public Task DeleteLevelAsync(
        int teamId,
        int levelId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.DeleteLevelAsync(teamId, levelId, actingUserId, cancellationToken);

    public Task DeleteBadgeAsync(
        int teamId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.DeleteBadgeAsync(teamId, badgeId, actingUserId, cancellationToken);

    public Task<ActionTypeDto> CreateActionTypeAsync(
        int teamId,
        CreateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.CreateActionTypeAsync(teamId, dto, actingUserId, cancellationToken);

    public Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForGamificationSetupAsync(
        int teamId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.GetActionTypesForGamificationSetupAsync(teamId, actingUserId, cancellationToken);

    public Task<ActionTypeDto> UpdateActionTypeAsync(
        int teamId,
        int actionTypeId,
        UpdateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.UpdateActionTypeAsync(teamId, actionTypeId, dto, actingUserId, cancellationToken);

    public Task DeleteActionTypeAsync(
        int teamId,
        int actionTypeId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.DeleteActionTypeAsync(teamId, actionTypeId, actingUserId, cancellationToken);

    public Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForMemberAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken) =>
        _gamificationSetup.GetActionTypesForMemberAsync(teamId, userId, cancellationToken);

    public Task RequestJoinTeamAsync(int teamId, int userId, CancellationToken cancellationToken) =>
        _joinRequests.RequestJoinTeamAsync(teamId, userId, cancellationToken);

    public Task<IReadOnlyList<MyPendingJoinRequestDto>> GetMyPendingJoinRequestsAsync(
        int userId,
        CancellationToken cancellationToken) =>
        _joinRequests.GetMyPendingJoinRequestsAsync(userId, cancellationToken);

    public Task CancelMyJoinRequestAsync(int teamId, int userId, CancellationToken cancellationToken) =>
        _joinRequests.CancelMyJoinRequestAsync(teamId, userId, cancellationToken);

    public Task<IReadOnlyList<TeamJoinRequestDto>> GetPendingJoinRequestsAsync(
        int teamId,
        int managerUserId,
        CancellationToken cancellationToken) =>
        _joinRequests.GetPendingJoinRequestsAsync(teamId, managerUserId, cancellationToken);

    public Task ApproveJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken) =>
        _joinRequests.ApproveJoinRequestAsync(teamId, requestId, approverUserId, cancellationToken);

    public Task RejectJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken) =>
        _joinRequests.RejectJoinRequestAsync(teamId, requestId, approverUserId, cancellationToken);

    public Task LeaveTeamAsync(int teamId, int userId, CancellationToken cancellationToken) =>
        _roster.LeaveTeamAsync(teamId, userId, cancellationToken);

    public Task RemoveTeamMemberAsync(
        int teamId,
        int targetUserId,
        int actingUserId,
        CancellationToken cancellationToken) =>
        _roster.RemoveTeamMemberAsync(teamId, targetUserId, actingUserId, cancellationToken);
}
