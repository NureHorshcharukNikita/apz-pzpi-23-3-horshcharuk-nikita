using System.Security.Claims;
using Elevate.Data;
using Elevate.Dtos.Users;
using Elevate.Mappings.Users;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Users;

public class UserService : IUserService
{
    private readonly ElevateDbContext _dbContext;

    public UserService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<UserProfileDto?> GetProfileAsync(int userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .Include(u => u.TeamMemberships)
                .ThenInclude(tm => tm.Team)
            .Include(u => u.TeamMemberships)
                .ThenInclude(tm => tm.TeamLevel)
            .Include(u => u.UserTeamBadges)
                .ThenInclude(utb => utb.Team)
            .Include(u => u.UserTeamBadges)
                .ThenInclude(utb => utb.TeamBadge)
            .FirstOrDefaultAsync(u => u.UserID == userId, cancellationToken);

        if (user is null)
        {
            return null;
        }

        return UserMappings.ToUserProfileDto(user);
    }

    public Task<UserProfileDto?> GetProfileAsync(
        ClaimsPrincipal principal,
        CancellationToken cancellationToken)
    {
        var subject =
            principal.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? principal.FindFirstValue("sub");

        if (!int.TryParse(subject, out var userId))
        {
            return Task.FromResult<UserProfileDto?>(null);
        }

        return GetProfileAsync(userId, cancellationToken);
    }

    public async Task<UserProfileDto?> UpdateProfileAsync(
        ClaimsPrincipal principal,
        string firstName,
        string lastName,
        string email,
        CancellationToken ct)
    {
        var userId = GetUserId(principal);
        var entity = await _dbContext.Users
            .Include(u => u.TeamMemberships)
                .ThenInclude(tm => tm.Team)
            .Include(u => u.TeamMemberships)
                .ThenInclude(tm => tm.TeamLevel)
            .Include(u => u.UserTeamBadges)
                .ThenInclude(utb => utb.Team)
            .Include(u => u.UserTeamBadges)
                .ThenInclude(utb => utb.TeamBadge)
            .FirstOrDefaultAsync(u => u.UserID == userId, ct);

        if (entity is null)
        {
            return null;
        }

        entity.FirstName = firstName.Trim();
        entity.LastName = lastName.Trim();
        entity.Email = email.Trim();

        await _dbContext.SaveChangesAsync(ct);

        return UserMappings.ToUserProfileDto(entity);
    }

    public async Task UpdateAvatarAsync(
        ClaimsPrincipal user,
        byte[] avatar,
        CancellationToken ct)
    {
        var userId = GetUserId(user);

        var entity = await _dbContext.Users
            .FirstOrDefaultAsync(x => x.UserID == userId, ct);

        if (entity is null)
        {
            throw new InvalidOperationException("User not found");
        }

        entity.Avatar = avatar;

        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task<byte[]?> GetAvatarAsync(
        ClaimsPrincipal user,
        CancellationToken ct)
    {
        var userId = GetUserId(user);

        return await _dbContext.Users
            .AsNoTracking()
            .Where(x => x.UserID == userId)
            .Select(x => x.Avatar)
            .FirstOrDefaultAsync(ct);
    }

    private static int GetUserId(ClaimsPrincipal user)
    {
        var subject =
            user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? user.FindFirstValue("sub");

        if (!int.TryParse(subject, out var userId))
        {
            throw new UnauthorizedAccessException("Invalid user claims");
        }

        return userId;
    }
}
