using Elevate.Data;
using Elevate.Entities;
using Elevate.Exceptions;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class TeamBadgesAdminService : ITeamBadgesAdminService
{
    private readonly ElevateDbContext _dbContext;
    private readonly IGamificationService _gamification;

    public TeamBadgesAdminService(ElevateDbContext dbContext, IGamificationService gamification)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _gamification = gamification ?? throw new ArgumentNullException(nameof(gamification));
    }

    public async Task<IReadOnlyList<TeamBadge>> GetTeamBadgesAsync(int teamId, CancellationToken ct = default)
    {
        return await _dbContext.TeamBadges
            .Where(b => b.TeamID == teamId)
            .OrderBy(b => b.Code)
            .ToListAsync(ct);
    }

    public async Task<TeamBadge> CreateTeamBadgeAsync(int teamId, string code, string name, string description,
        string iconCode, string conditionType, int conditionValue, CancellationToken ct = default)
    {
        var c = code.Trim();
        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(c))
        {
            throw new ClientErrorException("admin.apiErrorRequiredCode");
        }

        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        var badge = new TeamBadge
        {
            TeamID = teamId,
            Code = c,
            Name = n,
            Description = description,
            IconCode = iconCode,
            ConditionType = conditionType,
            ConditionValue = conditionValue
        };

        _dbContext.TeamBadges.Add(badge);
        await _dbContext.SaveChangesAsync(ct);

        await _gamification.AwardMissingBadgesForAllMembersAsync(teamId, ct);

        return badge;
    }

    public async Task UpdateTeamBadgeAsync(int badgeId, string name, string description, string iconCode,
        string conditionType, int conditionValue, CancellationToken ct = default)
    {
        var badge = await _dbContext.TeamBadges.FirstOrDefaultAsync(b => b.TeamBadgeID == badgeId, ct)
                    ?? throw new ClientErrorException("admin.apiErrorBadgeNotFound");

        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        badge.Name = n;
        badge.Description = description;
        badge.IconCode = iconCode;
        badge.ConditionType = conditionType;
        badge.ConditionValue = conditionValue;

        await _dbContext.SaveChangesAsync(ct);

        await _gamification.AwardMissingBadgesForAllMembersAsync(badge.TeamID, ct);
    }

    public async Task DeleteTeamBadgeAsync(int badgeId, CancellationToken ct = default)
    {
        var badge = await _dbContext.TeamBadges.FirstOrDefaultAsync(b => b.TeamBadgeID == badgeId, ct)
                    ?? throw new ClientErrorException("admin.apiErrorBadgeNotFound");

        _dbContext.TeamBadges.Remove(badge);
        await _dbContext.SaveChangesAsync(ct);
    }
}
