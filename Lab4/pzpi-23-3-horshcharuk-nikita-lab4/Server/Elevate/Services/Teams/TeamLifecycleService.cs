using Elevate.Data;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamLifecycleService : ITeamLifecycleService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;
    private readonly ITeamCatalogService _catalog;

    public TeamLifecycleService(
        ElevateDbContext dbContext,
        TeamServiceShared shared,
        ITeamCatalogService catalog)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
        _catalog = catalog ?? throw new ArgumentNullException(nameof(catalog));
    }

    public async Task<TeamDetailDto> CreateMyTeamAsync(
        string name,
        string? description,
        int? maxMembers,
        int creatorUserId,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new InvalidOperationException("Team name is required.");
        }

        if (maxMembers is < 1)
        {
            throw new InvalidOperationException(
                "MaxMembers must be at least 1 when set. Omit the field for unlimited size.");
        }

        var trimmed = name.Trim();
        var team = new Team
        {
            Name = trimmed,
            Description = string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
            CreatedAt = DateTime.UtcNow,
            CreatedByUserID = creatorUserId,
            MaxMembers = maxMembers
        };

        _dbContext.Teams.Add(team);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var member = new TeamMember
        {
            TeamID = team.TeamID,
            UserID = creatorUserId,
            TeamRole = "Lead",
            JoinedAt = DateTime.UtcNow,
            TeamPoints = 0,
            TeamLevelID = null
        };

        _dbContext.TeamMembers.Add(member);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var created = await _catalog.GetTeamAsync(team.TeamID, cancellationToken);
        return created
               ?? throw new InvalidOperationException("Failed to load created team.");
    }

    public async Task DeleteTeamAsync(int teamId, int userId, CancellationToken cancellationToken)
    {
        var team = await _dbContext.Teams
                       .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken)
                   ?? throw new InvalidOperationException("Team not found.");

        if (!await _shared.CanDeleteTeamAsync(team, userId, cancellationToken))
        {
            throw new UnauthorizedAccessException(
                "Only the team creator or an administrator can delete this team.");
        }

        _dbContext.Teams.Remove(team);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<TeamDetailDto> UpdateTeamAsync(
        int teamId,
        UpdateTeamDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            throw new InvalidOperationException("Team name is required.");
        }

        var team = await _dbContext.Teams
                       .FirstOrDefaultAsync(t => t.TeamID == teamId, cancellationToken)
                   ?? throw new InvalidOperationException("Team not found.");

        team.Name = dto.Name.Trim();
        team.Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim();

        if (dto.LevelPointsMode.HasValue)
        {
            team.LevelPointsMode = dto.LevelPointsMode.Value;
        }

        if (dto.UpdateMaxMembers)
        {
            if (dto.MaxMembers is < 1)
            {
                throw new InvalidOperationException(
                    "MaxMembers must be at least 1 when set, or use unlimited (null).");
            }

            if (dto.MaxMembers is int cap)
            {
                var count = await _dbContext.TeamMembers
                    .CountAsync(tm => tm.TeamID == teamId, cancellationToken);
                if (cap < count)
                {
                    throw new InvalidOperationException(
                        $"Cannot set max members below the current member count ({count}).");
                }
            }

            team.MaxMembers = dto.MaxMembers;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        var updated = await _catalog.GetTeamAsync(teamId, cancellationToken);
        return updated
               ?? throw new InvalidOperationException("Failed to load team after update.");
    }
}
