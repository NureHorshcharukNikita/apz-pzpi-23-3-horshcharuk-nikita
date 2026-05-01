using Elevate.Data;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamJoinRequestService : ITeamJoinRequestService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;

    public TeamJoinRequestService(ElevateDbContext dbContext, TeamServiceShared shared)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
    }

    public async Task RequestJoinTeamAsync(int teamId, int userId, CancellationToken cancellationToken)
    {
        await _shared.EnsureTeamExistsAsync(teamId, cancellationToken);

        var alreadyMember = await _dbContext.TeamMembers
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        if (alreadyMember)
        {
            return;
        }

        await _shared.EnsureTeamHasCapacityForNewMemberAsync(teamId, cancellationToken);

        var pending = await _dbContext.TeamJoinRequests
            .FirstOrDefaultAsync(
                r => r.TeamID == teamId && r.UserID == userId && r.Status == "Pending",
                cancellationToken);

        if (pending is not null)
        {
            return;
        }

        _dbContext.TeamJoinRequests.Add(
            new TeamJoinRequest
            {
                TeamID = teamId,
                UserID = userId,
                Status = "Pending",
                RequestedAt = DateTime.UtcNow
            });

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<MyPendingJoinRequestDto>> GetMyPendingJoinRequestsAsync(
        int userId,
        CancellationToken cancellationToken)
    {
        return await _dbContext.TeamJoinRequests
            .AsNoTracking()
            .Where(r =>
                r.UserID == userId &&
                r.Status == "Pending" &&
                !_dbContext.TeamMembers.Any(m =>
                    m.TeamID == r.TeamID && m.UserID == userId))
            .OrderBy(r => r.RequestedAt)
            .Select(r => new MyPendingJoinRequestDto
            {
                Id = r.TeamJoinRequestID,
                TeamId = r.TeamID,
                TeamName = r.Team.Name,
                Status = r.Status,
                RequestedAt = r.RequestedAt
            })
            .ToListAsync(cancellationToken);
    }

    public async Task CancelMyJoinRequestAsync(int teamId, int userId, CancellationToken cancellationToken)
    {
        var request = await _dbContext.TeamJoinRequests
            .FirstOrDefaultAsync(
                r => r.TeamID == teamId && r.UserID == userId && r.Status == "Pending",
                cancellationToken);

        if (request is null)
        {
            throw new InvalidOperationException("No pending join request for this team.");
        }

        _dbContext.TeamJoinRequests.Remove(request);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<TeamJoinRequestDto>> GetPendingJoinRequestsAsync(
        int teamId,
        int managerUserId,
        CancellationToken cancellationToken)
    {
        if (!await _shared.CanManageJoinRequestsAsync(teamId, managerUserId, cancellationToken))
        {
            throw new UnauthorizedAccessException("Only team leads or administrators can view join requests.");
        }

        await _shared.EnsureTeamExistsAsync(teamId, cancellationToken);

        return await _dbContext.TeamJoinRequests
            .AsNoTracking()
            .Where(r =>
                r.TeamID == teamId &&
                r.Status == "Pending" &&
                !_dbContext.TeamMembers.Any(m =>
                    m.TeamID == teamId && m.UserID == r.UserID))
            .OrderBy(r => r.RequestedAt)
            .Select(r => new TeamJoinRequestDto
            {
                Id = r.TeamJoinRequestID,
                TeamId = r.TeamID,
                UserId = r.UserID,
                UserFullName = r.User.FirstName + " " + r.User.LastName,
                Status = r.Status,
                RequestedAt = r.RequestedAt
            })
            .ToListAsync(cancellationToken);
    }

    public async Task ApproveJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken)
    {
        if (!await _shared.CanManageJoinRequestsAsync(teamId, approverUserId, cancellationToken))
        {
            throw new UnauthorizedAccessException("Only team leads or administrators can approve join requests.");
        }

        var request = await _dbContext.TeamJoinRequests
            .FirstOrDefaultAsync(
                r => r.TeamJoinRequestID == requestId && r.TeamID == teamId,
                cancellationToken);

        if (request is null || request.Status != "Pending")
        {
            throw new InvalidOperationException("Join request not found or already processed.");
        }

        var alreadyMember = await _dbContext.TeamMembers
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == request.UserID, cancellationToken);

        if (alreadyMember)
        {
            request.Status = "Approved";
            request.ProcessedAt = DateTime.UtcNow;
            request.ProcessedByUserID = approverUserId;
            await _dbContext.SaveChangesAsync(cancellationToken);
            return;
        }

        await _shared.EnsureTeamHasCapacityForNewMemberAsync(teamId, cancellationToken);

        await _shared.AddTeamMemberCoreAsync(teamId, request.UserID, cancellationToken);

        request.Status = "Approved";
        request.ProcessedAt = DateTime.UtcNow;
        request.ProcessedByUserID = approverUserId;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task RejectJoinRequestAsync(
        int teamId,
        int requestId,
        int approverUserId,
        CancellationToken cancellationToken)
    {
        if (!await _shared.CanManageJoinRequestsAsync(teamId, approverUserId, cancellationToken))
        {
            throw new UnauthorizedAccessException("Only team leads or administrators can reject join requests.");
        }

        var request = await _dbContext.TeamJoinRequests
            .FirstOrDefaultAsync(
                r => r.TeamJoinRequestID == requestId && r.TeamID == teamId,
                cancellationToken);

        if (request is null || request.Status != "Pending")
        {
            throw new InvalidOperationException("Join request not found or already processed.");
        }

        request.Status = "Rejected";
        request.ProcessedAt = DateTime.UtcNow;
        request.ProcessedByUserID = approverUserId;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
