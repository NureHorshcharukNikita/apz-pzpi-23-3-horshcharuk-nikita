using System.Collections.Generic;
using Elevate.Entities;
using Elevate.Services.Gamification;

namespace Elevate.Tests.TestUtilities;

internal sealed class NoOpGamificationService : IGamificationService
{
    public Task<IReadOnlyCollection<UserTeamBadge>> EvaluateBadgesAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyCollection<UserTeamBadge>>(Array.Empty<UserTeamBadge>());

    public Task<TeamLevel?> UpdateMembershipLevelAsync(
        TeamMember membership,
        int teamId,
        CancellationToken cancellationToken) =>
        Task.FromResult<TeamLevel?>(null);

    public Task<int> AwardMissingBadgesForAllMembersAsync(
        int teamId,
        CancellationToken cancellationToken) =>
        Task.FromResult(0);
}
