using Elevate.Data;
using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Elevate.Mappings.Teams;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Teams;

internal sealed class TeamGamificationSetupService : ITeamGamificationSetupService
{
    private readonly ElevateDbContext _dbContext;
    private readonly TeamServiceShared _shared;
    private readonly IGamificationService _gamification;

    public TeamGamificationSetupService(
        ElevateDbContext dbContext,
        TeamServiceShared shared,
        IGamificationService gamification)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _shared = shared ?? throw new ArgumentNullException(nameof(shared));
        _gamification = gamification ?? throw new ArgumentNullException(nameof(gamification));
    }

    public async Task<TeamLevelDto> CreateLevelAsync(
        int teamId,
        CreateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        if (dto.OrderIndex < 1)
        {
            throw new InvalidOperationException(
                "Level number must be at least 1. Set orderIndex to the level you are defining (e.g. 2 for level 2).");
        }

        await _shared.EnsureTeamLevelOrderUniqueAsync(teamId, dto.OrderIndex, exceptLevelId: null, cancellationToken);

        var level = new TeamLevel
        {
            TeamID = teamId,
            Name = string.IsNullOrWhiteSpace(dto.Name) ? string.Empty : dto.Name.Trim(),
            RequiredPoints = dto.RequiredPoints,
            OrderIndex = dto.OrderIndex
        };

        _dbContext.TeamLevels.Add(level);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return TeamMappings.ToTeamLevelDto(level);
    }

    public async Task<TeamBadgeDto> CreateBadgeAsync(
        int teamId,
        CreateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        TeamServiceShared.ValidateBadgeAwardCondition(dto.ConditionType, dto.ConditionValue);

        var badge = new TeamBadge
        {
            TeamID = teamId,
            Code = dto.Code,
            Name = dto.Name,
            Description = dto.Description,
            IconCode = dto.IconCode,
            ConditionType = dto.ConditionType,
            ConditionValue = dto.ConditionValue
        };

        _dbContext.TeamBadges.Add(badge);
        await _dbContext.SaveChangesAsync(cancellationToken);

        await _gamification.AwardMissingBadgesForAllMembersAsync(teamId, cancellationToken);

        return TeamMappings.ToTeamBadgeDto(badge);
    }

    public async Task<TeamLevelDto> UpdateLevelAsync(
        int teamId,
        int levelId,
        UpdateTeamLevelDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        if (dto.OrderIndex < 1)
        {
            throw new InvalidOperationException("Level number must be at least 1.");
        }

        await _shared.EnsureTeamLevelOrderUniqueAsync(teamId, dto.OrderIndex, exceptLevelId: levelId, cancellationToken);

        var level = await _dbContext.TeamLevels
                        .FirstOrDefaultAsync(
                            l => l.TeamID == teamId && l.TeamLevelID == levelId,
                            cancellationToken)
                    ?? throw new InvalidOperationException("Level not found.");

        level.Name = string.IsNullOrWhiteSpace(dto.Name) ? string.Empty : dto.Name.Trim();
        level.RequiredPoints = dto.RequiredPoints;
        level.OrderIndex = dto.OrderIndex;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return TeamMappings.ToTeamLevelDto(level);
    }

    public async Task<TeamBadgeDto> UpdateBadgeAsync(
        int teamId,
        int badgeId,
        UpdateTeamBadgeDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            throw new InvalidOperationException("Badge name is required.");
        }

        TeamServiceShared.ValidateBadgeAwardCondition(dto.ConditionType, dto.ConditionValue);

        var badge = await _dbContext.TeamBadges
                        .FirstOrDefaultAsync(
                            b => b.TeamID == teamId && b.TeamBadgeID == badgeId,
                            cancellationToken)
                    ?? throw new InvalidOperationException("Badge not found.");

        badge.Name = dto.Name.Trim();
        badge.Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim();
        badge.IconCode = string.IsNullOrWhiteSpace(dto.IconCode) ? null : dto.IconCode.Trim();
        badge.ConditionType = string.IsNullOrWhiteSpace(dto.ConditionType) ? null : dto.ConditionType.Trim();
        badge.ConditionValue = dto.ConditionValue;

        await _dbContext.SaveChangesAsync(cancellationToken);

        await _gamification.AwardMissingBadgesForAllMembersAsync(teamId, cancellationToken);

        return TeamMappings.ToTeamBadgeDto(badge);
    }

    public async Task DeleteLevelAsync(
        int teamId,
        int levelId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var level = await _dbContext.TeamLevels
                        .FirstOrDefaultAsync(
                            l => l.TeamID == teamId && l.TeamLevelID == levelId,
                            cancellationToken)
                    ?? throw new InvalidOperationException("Level not found.");

        var membersOnLevel = await _dbContext.TeamMembers
            .Where(tm => tm.TeamLevelID == levelId)
            .ToListAsync(cancellationToken);

        foreach (var tm in membersOnLevel)
        {
            tm.TeamLevelID = null;
        }

        _dbContext.TeamLevels.Remove(level);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteBadgeAsync(
        int teamId,
        int badgeId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var badge = await _dbContext.TeamBadges
                        .FirstOrDefaultAsync(
                            b => b.TeamID == teamId && b.TeamBadgeID == badgeId,
                            cancellationToken)
                    ?? throw new InvalidOperationException("Badge not found.");

        _dbContext.TeamBadges.Remove(badge);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<ActionTypeDto> CreateActionTypeAsync(
        int teamId,
        CreateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var actionType = new ActionType
        {
            TeamID = teamId,
            Code = dto.Code,
            Name = dto.Name,
            Description = dto.Description,
            DefaultPoints = dto.DefaultPoints,
            Category = dto.Category,
            IsActive = dto.IsActive
        };

        _dbContext.ActionTypes.Add(actionType);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new ActionTypeDto
        {
            Id = actionType.ActionTypeID,
            TeamId = actionType.TeamID,
            Code = actionType.Code,
            Name = actionType.Name,
            Description = actionType.Description,
            DefaultPoints = actionType.DefaultPoints,
            Category = actionType.Category,
            IsActive = actionType.IsActive
        };
    }

    public async Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForGamificationSetupAsync(
        int teamId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var types = await _dbContext.ActionTypes
            .AsNoTracking()
            .Where(at => at.TeamID == teamId)
            .OrderBy(at => at.Name)
            .Select(at => new ActionTypeDto
            {
                Id = at.ActionTypeID,
                TeamId = at.TeamID,
                Code = at.Code,
                Name = at.Name,
                Description = at.Description,
                DefaultPoints = at.DefaultPoints,
                Category = at.Category ?? string.Empty,
                IsActive = at.IsActive
            })
            .ToListAsync(cancellationToken);

        return types;
    }

    public async Task<ActionTypeDto> UpdateActionTypeAsync(
        int teamId,
        int actionTypeId,
        UpdateActionTypeDto dto,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            throw new InvalidOperationException("Action type name is required.");
        }

        var actionType = await _dbContext.ActionTypes
                             .FirstOrDefaultAsync(
                                 at => at.TeamID == teamId && at.ActionTypeID == actionTypeId,
                                 cancellationToken)
                         ?? throw new InvalidOperationException("Action type not found.");

        actionType.Name = dto.Name.Trim();
        actionType.Description = string.IsNullOrWhiteSpace(dto.Description) ? null : dto.Description.Trim();
        actionType.DefaultPoints = dto.DefaultPoints;
        actionType.Category = string.IsNullOrWhiteSpace(dto.Category) ? null : dto.Category.Trim();
        actionType.IsActive = dto.IsActive;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return new ActionTypeDto
        {
            Id = actionType.ActionTypeID,
            TeamId = actionType.TeamID,
            Code = actionType.Code,
            Name = actionType.Name,
            Description = actionType.Description,
            DefaultPoints = actionType.DefaultPoints,
            Category = actionType.Category ?? string.Empty,
            IsActive = actionType.IsActive
        };
    }

    public async Task DeleteActionTypeAsync(
        int teamId,
        int actionTypeId,
        int actingUserId,
        CancellationToken cancellationToken)
    {
        await _shared.EnsureCanManageTeamGamificationAsync(teamId, actingUserId, cancellationToken);

        var actionType = await _dbContext.ActionTypes
                             .FirstOrDefaultAsync(
                                 at => at.TeamID == teamId && at.ActionTypeID == actionTypeId,
                                 cancellationToken)
                         ?? throw new InvalidOperationException("Action type not found.");

        var hasEvents = await _dbContext.ActionEvents
            .AnyAsync(ae => ae.ActionTypeID == actionTypeId, cancellationToken);

        if (hasEvents)
        {
            throw new InvalidOperationException(
                "Cannot delete an action type that has logged events. Deactivate it instead.");
        }

        _dbContext.ActionTypes.Remove(actionType);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyCollection<ActionTypeDto>> GetActionTypesForMemberAsync(
        int teamId,
        int userId,
        CancellationToken cancellationToken)
    {
        var isMember = await _dbContext.TeamMembers
            .AsNoTracking()
            .AnyAsync(tm => tm.TeamID == teamId && tm.UserID == userId, cancellationToken);

        if (!isMember)
        {
            return Array.Empty<ActionTypeDto>();
        }

        var types = await _dbContext.ActionTypes
            .AsNoTracking()
            .Where(at => at.TeamID == teamId && at.IsActive)
            .OrderBy(at => at.Name)
            .Select(at => new ActionTypeDto
            {
                Id = at.ActionTypeID,
                TeamId = at.TeamID,
                Code = at.Code,
                Name = at.Name,
                Description = at.Description,
                DefaultPoints = at.DefaultPoints,
                Category = at.Category ?? string.Empty,
                IsActive = at.IsActive
            })
            .ToListAsync(cancellationToken);

        return types;
    }
}
