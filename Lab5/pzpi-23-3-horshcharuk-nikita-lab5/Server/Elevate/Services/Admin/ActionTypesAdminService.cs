using Elevate.Data;
using Elevate.Entities;
using Elevate.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class ActionTypesAdminService : IActionTypesAdminService
{
    private readonly ElevateDbContext _dbContext;

    public ActionTypesAdminService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public async Task<IReadOnlyList<ActionType>> GetActionTypesAsync(int teamId, CancellationToken ct = default)
    {
        return await _dbContext.ActionTypes
            .Where(a => a.TeamID == teamId)
            .OrderBy(a => a.Code)
            .ToListAsync(ct);
    }

    public async Task<ActionType> CreateActionTypeAsync(int teamId, string code, string name, string description,
        int defaultPoints, string category, bool isActive, CancellationToken ct = default)
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

        var actionType = new ActionType
        {
            TeamID = teamId,
            Code = c,
            Name = n,
            Description = description,
            DefaultPoints = defaultPoints,
            Category = category,
            IsActive = isActive
        };

        _dbContext.ActionTypes.Add(actionType);
        await _dbContext.SaveChangesAsync(ct);
        return actionType;
    }

    public async Task UpdateActionTypeAsync(int actionTypeId, string name, string description,
        int defaultPoints, string category, bool isActive, CancellationToken ct = default)
    {
        var actionType = await _dbContext.ActionTypes.FirstOrDefaultAsync(a => a.ActionTypeID == actionTypeId, ct)
                         ?? throw new ClientErrorException("admin.apiErrorActionTypeNotFound");

        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        actionType.Name = n;
        actionType.Description = description;
        actionType.DefaultPoints = defaultPoints;
        actionType.Category = category;
        actionType.IsActive = isActive;

        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task DeleteActionTypeAsync(int actionTypeId, CancellationToken ct = default)
    {
        var actionType = await _dbContext.ActionTypes.FirstOrDefaultAsync(a => a.ActionTypeID == actionTypeId, ct)
                         ?? throw new ClientErrorException("admin.apiErrorActionTypeNotFound");

        var hasEvents = await _dbContext.ActionEvents.AnyAsync(ae => ae.ActionTypeID == actionTypeId, ct);
        if (hasEvents)
        {
            throw new ClientErrorException("admin.apiErrorActionTypeHasEvents");
        }

        _dbContext.ActionTypes.Remove(actionType);
        await _dbContext.SaveChangesAsync(ct);
    }
}
