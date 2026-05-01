using Elevate.Data;
using Elevate.Dtos.Admin.Gamification.Levels;
using Elevate.Entities;
using Elevate.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class TeamLevelsAdminService : ITeamLevelsAdminService
{
    private readonly ElevateDbContext _dbContext;

    public TeamLevelsAdminService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public async Task<TeamLevelsForAdminDto> GetTeamLevelsForAdminAsync(int teamId, CancellationToken ct = default)
    {
        var modeRow = await _dbContext.Teams
            .AsNoTracking()
            .Where(t => t.TeamID == teamId)
            .Select(t => new { t.LevelPointsMode })
            .FirstOrDefaultAsync(ct);

        if (modeRow is null)
        {
            throw new ClientErrorException("admin.apiErrorTeamNotFound");
        }

        var levels = await _dbContext.TeamLevels
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(ct);

        return new TeamLevelsForAdminDto
        {
            Levels = levels,
            LevelPointsMode = (int)modeRow.LevelPointsMode,
        };
    }

    public async Task<IReadOnlyList<TeamLevel>> GetTeamLevelsAsync(int teamId, CancellationToken ct = default)
    {
        return await _dbContext.TeamLevels
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .ToListAsync(ct);
    }

    public async Task<TeamLevel> CreateTeamLevelAsync(int teamId, string name, int requiredPoints, int orderIndex, CancellationToken ct = default)
    {
        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        var level = new TeamLevel
        {
            TeamID = teamId,
            Name = n,
            RequiredPoints = requiredPoints,
            OrderIndex = orderIndex
        };

        _dbContext.TeamLevels.Add(level);
        await _dbContext.SaveChangesAsync(ct);
        return level;
    }

    public async Task UpdateTeamLevelAsync(int levelId, string name, int requiredPoints, int orderIndex, CancellationToken ct = default)
    {
        var level = await _dbContext.TeamLevels.FirstOrDefaultAsync(l => l.TeamLevelID == levelId, ct)
                     ?? throw new ClientErrorException("admin.apiErrorLevelNotFound");

        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        level.Name = n;
        level.RequiredPoints = requiredPoints;
        level.OrderIndex = orderIndex;

        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task DeleteTeamLevelAsync(int levelId, CancellationToken ct = default)
    {
        var level = await _dbContext.TeamLevels.FirstOrDefaultAsync(l => l.TeamLevelID == levelId, ct)
                     ?? throw new ClientErrorException("admin.apiErrorLevelNotFound");

        await _dbContext.TeamMembers
            .Where(m => m.TeamLevelID == levelId)
            .ExecuteUpdateAsync(s => s.SetProperty(m => m.TeamLevelID, (int?)null), ct);

        _dbContext.TeamLevels.Remove(level);
        await _dbContext.SaveChangesAsync(ct);
    }
}
