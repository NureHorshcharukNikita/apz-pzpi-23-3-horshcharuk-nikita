using Elevate.Data;
using Elevate.Dtos.Actions;
using Elevate.Entities;
using Elevate.Mappings.Actions;
using Elevate.Services.Gamification;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Actions;

public class ActionEventService : IActionEventService
{
    private readonly ElevateDbContext _dbContext;
    private readonly IGamificationService _gamificationService;
    private readonly ActionEventValidator _validator;

    public ActionEventService(
        ElevateDbContext dbContext,
        IGamificationService gamificationService,
        ActionEventValidator validator)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _gamificationService = gamificationService ?? throw new ArgumentNullException(nameof(gamificationService));
        _validator = validator ?? throw new ArgumentNullException(nameof(validator));
    }

    public async Task<ActionEventDto> CreateActionEventAsync(
        CreateActionEventDto dto,
        int? authenticatedUserId,
        CancellationToken cancellationToken)
    {
        var userId = _validator.ResolveUserId(dto, authenticatedUserId);

        var actionType = await _validator.ValidateAndGetActionTypeAsync(dto, cancellationToken);
        var membership = await _validator.ValidateAndGetMembershipAsync(userId, dto.TeamId, cancellationToken);

        var points = dto.Points ?? actionType.DefaultPoints;

        var rawLevels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(tl => tl.TeamID == dto.TeamId)
            .OrderBy(tl => tl.OrderIndex)
            .ToListAsync(cancellationToken);

        var pointsBefore = membership.TeamPoints;
        var prevReachedLevel = rawLevels.Count == 0
            ? 0
            : TeamLevelProgressCalculator.Compute(pointsBefore, rawLevels).Level;

        var actionEvent = CreateActionEventEntity(dto, userId, points);

        _dbContext.ActionEvents.Add(actionEvent);
        membership.TeamPoints += points;

        var newLevel = await _gamificationService.UpdateMembershipLevelAsync(membership, dto.TeamId, cancellationToken);

        await _dbContext.SaveChangesAsync(cancellationToken);

        var earnedBadges = await _gamificationService.EvaluateBadgesAsync(
            dto.TeamId,
            userId,
            cancellationToken);

        var progressAfter = rawLevels.Count == 0
            ? (Level: 0, CurrentXp: 0, NextLevelXp: 0, TierName: (string?)null, AtMaxTier: false)
            : TeamLevelProgressCalculator.Compute(membership.TeamPoints, rawLevels);

        var leveledUp = progressAfter.Level > prevReachedLevel;

        string? membershipLevelName = null;
        if (leveledUp)
        {
            membershipLevelName = FormatTeamLevelDisplayName(newLevel)
                ?? FormatTeamLevelDisplayName(membership.TeamLevel);

            if (string.IsNullOrWhiteSpace(membershipLevelName))
            {
                if (!string.IsNullOrWhiteSpace(progressAfter.TierName))
                {
                    membershipLevelName = progressAfter.TierName;
                }
                else if (progressAfter.Level > 0)
                {
                    membershipLevelName = $"Level {progressAfter.Level}";
                }
            }
        }

        var badgeLookup = earnedBadges
            .Select(b => b.TeamBadge)
            .Where(tb => tb != null)
            .Cast<TeamBadge>()
            .ToDictionary(tb => tb.TeamBadgeID, tb => tb.Name);

        return ActionEventMappings.ToActionEventDto(
            actionEvent,
            membership,
            membershipLevelName,
            earnedBadges,
            badgeLookup);
    }

    public async Task<IReadOnlyCollection<ActionEventDto>> GetActionEventsAsync(
        int? userId,
        int? teamId,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.ActionEvents.AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(ae => ae.UserID == userId.Value);
        }

        if (teamId.HasValue)
        {
            query = query.Where(ae => ae.TeamID == teamId.Value);
        }

        var results = await query
            .AsNoTracking()
            .OrderByDescending(ae => ae.OccurredAt)
            .Take(100)
            .Select(ActionEventMappings.ToListItem)
            .ToListAsync(cancellationToken);

        return results;
    }

    public Task<ActionEvent?> GetActionEventByIdAsync(int id, CancellationToken cancellationToken) =>
        _dbContext.ActionEvents
            .AsNoTracking()
            .Include(ae => ae.User)
            .Include(ae => ae.ActionType)
            .FirstOrDefaultAsync(ae => ae.ActionEventID == id, cancellationToken);

    private static string? FormatTeamLevelDisplayName(TeamLevel? level)
    {
        if (level is null)
        {
            return null;
        }

        var name = level.Name?.Trim();
        if (!string.IsNullOrEmpty(name))
        {
            return name;
        }

        return $"Level {level.OrderIndex}";
    }

    private static ActionEvent CreateActionEventEntity(
        CreateActionEventDto dto,
        int userId,
        int points)
    {
        return new ActionEvent
        {
            UserID = userId,
            TeamID = dto.TeamId,
            ActionTypeID = dto.ActionTypeId,
            SourceType = dto.SourceType,
            SourceUserID = dto.SourceUserId,
            Comment = dto.Comment,
            PointsAwarded = points,
            OccurredAt = dto.OccurredAt ?? DateTime.UtcNow
        };
    }
}
