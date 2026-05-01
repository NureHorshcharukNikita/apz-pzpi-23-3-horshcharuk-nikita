using Elevate.Data;
using Elevate.Dtos.Teams;
using Elevate.Mappings.Teams;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamCatalogService : ITeamCatalogService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;

    public TeamCatalogService(ElevateDbContext dbContext, TeamServiceShared shared)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
    }

    public async Task<IReadOnlyCollection<TeamDto>> GetTeamsAsync(CancellationToken cancellationToken)
    {
        var teams = await _dbContext.Teams
            .AsNoTracking()
            .OrderBy(t => t.Name)
            .Select(t => new TeamDto
            {
                Id = t.TeamID,
                Name = t.Name,
                Description = t.Description,
                CreatedAt = t.CreatedAt,
                CreatedByUserId = t.CreatedByUserID,
                MaxMembers = t.MaxMembers,
                MemberCount = t.Members.Count()
            })
            .ToListAsync(cancellationToken);

        return teams;
    }

    public async Task<TeamDetailDto?> GetTeamAsync(int id, CancellationToken cancellationToken)
    {
        var team = await _shared.GetTeamWithDetailsQuery()
            .FirstOrDefaultAsync(t => t.TeamID == id, cancellationToken);

        if (team is null)
        {
            return null;
        }

        var levelsOrdered = team.Levels.OrderBy(l => l.OrderIndex).ToList();

        return new TeamDetailDto
        {
            Id = team.TeamID,
            Name = team.Name,
            Description = team.Description,
            CreatedAt = team.CreatedAt,
            CreatedByUserId = team.CreatedByUserID,
            MaxMembers = team.MaxMembers,
            MemberCount = team.Members.Count,
            LevelPointsMode = team.LevelPointsMode,
            Members = team.Members
                .OrderByDescending(tm => tm.TeamPoints)
                .Select(tm => TeamMappings.ToTeamMemberDto(tm, levelsOrdered))
                .ToArray(),
            Levels = team.Levels
                .OrderBy(tl => tl.OrderIndex)
                .Select(TeamMappings.ToTeamLevelDto)
                .ToArray(),
            Badges = team.Badges
                .Select(TeamMappings.ToTeamBadgeDto)
                .ToArray()
        };
    }
}
