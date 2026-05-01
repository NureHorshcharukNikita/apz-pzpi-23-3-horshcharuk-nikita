using Elevate.Data;
using Elevate.Entities;
using Elevate.Exceptions;
using Elevate.Services.Auth.Tokens;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Elevate.Services.Admin;

public class AdminUserService : IAdminUserService
{
    private const int MinPasswordLength = 4;

    private readonly ElevateDbContext _dbContext;
    private readonly IPasswordHasher<User> _passwordHasher;
    private readonly WebAdministrationOptions _webAdmin;

    public AdminUserService(
        ElevateDbContext dbContext,
        IPasswordHasher<User> passwordHasher,
        IOptions<WebAdministrationOptions> webAdministrationOptions)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _webAdmin = webAdministrationOptions?.Value ?? throw new ArgumentNullException(nameof(webAdministrationOptions));
    }

    public async Task<User> CreateUserAsync(
        string login,
        string email,
        string password,
        string firstName,
        string lastName,
        string role,
        CancellationToken ct = default)
    {
        var l = login.Trim();
        var e = email.Trim();
        var fn = firstName.Trim();
        var ln = lastName.Trim();

        if (string.IsNullOrWhiteSpace(l) ||
            string.IsNullOrWhiteSpace(e) ||
            string.IsNullOrWhiteSpace(password) ||
            string.IsNullOrWhiteSpace(fn) ||
            string.IsNullOrWhiteSpace(ln))
        {
            throw new ClientErrorException("admin.apiErrorUserCreateInvalidFields");
        }

        if (password.Length < MinPasswordLength)
        {
            throw new ClientErrorException(
                "admin.apiErrorPasswordTooShort",
                new Dictionary<string, string> { ["min"] = MinPasswordLength.ToString() });
        }

        if (role is not (
                UserRoleNames.User
                or UserRoleNames.Manager
                or UserRoleNames.Admin
                or UserRoleNames.SystemAdministrator))
        {
            throw new ClientErrorException("admin.apiErrorInvalidRole");
        }

        if (string.Equals(l, _webAdmin.Login.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            throw new ClientErrorException("admin.apiErrorUserCreateReservedLogin");
        }

        var normLogin = l.ToLowerInvariant();
        var normEmail = e.ToLowerInvariant();
        var taken = await _dbContext.Users.AnyAsync(
            u => u.Login.ToLower() == normLogin || u.Email.ToLower() == normEmail,
            ct);

        if (taken)
        {
            throw new ClientErrorException("admin.apiErrorLoginOrEmailTaken");
        }

        var user = new User
        {
            Login = l,
            Email = e,
            FirstName = fn,
            LastName = ln,
            Role = role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
        };

        user.PasswordHash = _passwordHasher.HashPassword(user, password);
        user.PasswordPlain = password;
        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(ct);
        return user;
    }

    public async Task<IReadOnlyList<User>> GetAllAsync(CancellationToken ct = default)
    {
        return await _dbContext.Users
            .OrderBy(u => u.UserID)
            .ToListAsync(ct);
    }

    public async Task<User?> GetByIdAsync(int userId, CancellationToken ct = default)
    {
        return await _dbContext.Users
            .FirstOrDefaultAsync(u => u.UserID == userId, ct);
    }

    public async Task SetRoleAsync(int userId, string role, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserID == userId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorUserNotFound");

        if (role is not (
                UserRoleNames.User
                or UserRoleNames.Manager
                or UserRoleNames.Admin
                or UserRoleNames.SystemAdministrator))
            throw new ClientErrorException("admin.apiErrorInvalidRole");

        user.Role = role;
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task SetActiveAsync(int userId, bool isActive, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserID == userId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorUserNotFound");

        user.IsActive = isActive;
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task UpdateUserAsync(
        int userId,
        string login,
        string email,
        string firstName,
        string lastName,
        string? newPassword,
        bool clearPasswordPlain,
        CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserID == userId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorUserNotFound");

        var l = login.Trim();
        var e = email.Trim();
        var fn = firstName.Trim();
        var ln = lastName.Trim();

        if (string.IsNullOrWhiteSpace(l) ||
            string.IsNullOrWhiteSpace(e) ||
            string.IsNullOrWhiteSpace(fn) ||
            string.IsNullOrWhiteSpace(ln))
        {
            throw new ClientErrorException("admin.apiErrorUserProfileInvalidFields");
        }

        var reservedLogin = _webAdmin.Login.Trim();
        if (string.Equals(l, reservedLogin, StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(user.Login, reservedLogin, StringComparison.OrdinalIgnoreCase))
        {
            throw new ClientErrorException("admin.apiErrorUserCreateReservedLogin");
        }

        var normLogin = l.ToLowerInvariant();
        var loginTaken = await _dbContext.Users.AnyAsync(
            u => u.UserID != userId && u.Login.ToLower() == normLogin,
            ct);
        if (loginTaken)
        {
            throw new ClientErrorException("admin.apiErrorLoginOrEmailTaken");
        }

        var normEmail = e.ToLowerInvariant();
        var emailTaken = await _dbContext.Users.AnyAsync(
            u => u.UserID != userId && u.Email.ToLower() == normEmail,
            ct);

        if (emailTaken)
        {
            throw new ClientErrorException("admin.apiErrorEmailInUse");
        }

        user.Login = l;
        user.Email = e;
        user.FirstName = fn;
        user.LastName = ln;

        if (clearPasswordPlain)
        {
            user.PasswordPlain = null;
        }

        if (!string.IsNullOrWhiteSpace(newPassword))
        {
            var pwd = newPassword.Trim();
            if (pwd.Length < MinPasswordLength)
            {
                throw new ClientErrorException(
                    "admin.apiErrorPasswordTooShort",
                    new Dictionary<string, string> { ["min"] = MinPasswordLength.ToString() });
            }

            user.PasswordHash = _passwordHasher.HashPassword(user, pwd);
            user.PasswordPlain = pwd;
        }

        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task DeleteUserAsync(int userId, CancellationToken ct = default)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserID == userId, ct)
                   ?? throw new ClientErrorException("admin.apiErrorUserNotFound");

        await _dbContext.Teams
            .Where(t => t.CreatedByUserID == userId)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.CreatedByUserID, (int?)null), ct);

        await _dbContext.ActionEvents
            .Where(a => a.SourceUserID == userId)
            .ExecuteUpdateAsync(s => s.SetProperty(a => a.SourceUserID, (int?)null), ct);

        _dbContext.Users.Remove(user);
        await _dbContext.SaveChangesAsync(ct);
    }
}
