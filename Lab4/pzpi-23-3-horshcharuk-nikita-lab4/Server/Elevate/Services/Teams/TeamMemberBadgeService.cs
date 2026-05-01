using Elevate.Data;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamMemberBadgeService : ITeamMemberBadgeService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;

    public TeamMemberBadgeService(ElevateDbContext dbContext, TeamServiceShared shared)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
    }

    public async Task<IReadOnlyList<MemberBadgeAwardDto>> GetMemberBadgeAwardsAsync(
        int teamId,
        int memberUserId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var isMember = await _dbContext.TeamMembers
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == memberUserId, cancellationToken);

        if (!isMember)
        {
            throw new InvalidOperationException("User is not a member of this team.");
        }

        var awards = await _dbContext.UserTeamBadges
            .AsNoTracking()
            .Where(utb => utb.TeamID == teamId && utb.UserID == memberUserId)
            .Include(utb => utb.TeamBadge)
            .OrderByDescending(utb => utb.AwardedAt)
            .ToListAsync(cancellationToken);

        return awards
            .Select(a => new MemberBadgeAwardDto
            {
                UserTeamBadgeId = a.UserTeamBadgeID,
                TeamBadgeId = a.TeamBadgeID,
                BadgeName = a.TeamBadge.Name,
                AwardedAt = a.AwardedAt
            })
            .ToArray();
    }

    public async Task<MemberBadgeAwardDto> GrantMemberBadgeAsync(
        int teamId,
        int memberUserId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var isMember = await _dbContext.TeamMembers
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == memberUserId, cancellationToken);

        if (!isMember)
        {
            throw new InvalidOperationException("User is not a member of this team.");
        }

        var badge = await _dbContext.TeamBadges
            .FirstOrDefaultAsync(
                tb => tb.TeamBadgeID == badgeId && tb.TeamID == teamId,
                cancellationToken);

        if (badge is null)
        {
            throw new InvalidOperationException("Badge not found for this team.");
        }

        var exists = await _dbContext.UserTeamBadges
            .AnyAsync(
                utb => utb.TeamID == teamId
                    && utb.UserID == memberUserId
                    && utb.TeamBadgeID == badgeId,
                cancellationToken);

        if (exists)
        {
            throw new InvalidOperationException("This badge is already awarded to the member.");
        }

        var row = new UserTeamBadge
        {
            TeamID = teamId,
            UserID = memberUserId,
            TeamBadgeID = badgeId,
            TeamBadge = badge
        };

        _dbContext.UserTeamBadges.Add(row);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new MemberBadgeAwardDto
        {
            UserTeamBadgeId = row.UserTeamBadgeID,
            TeamBadgeId = badgeId,
            BadgeName = badge.Name,
            AwardedAt = row.AwardedAt
        };
    }

    public async Task RevokeMemberBadgeAwardAsync(
        int teamId,
        int memberUserId,
        int userTeamBadgeId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var award = await _dbContext.UserTeamBadges
            .FirstOrDefaultAsync(
                utb => utb.UserTeamBadgeID == userTeamBadgeId
                    && utb.TeamID == teamId
                    && utb.UserID == memberUserId,
                cancellationToken);

        if (award is null)
        {
            throw new InvalidOperationException("Badge award not found.");
        }

        _dbContext.UserTeamBadges.Remove(award);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
