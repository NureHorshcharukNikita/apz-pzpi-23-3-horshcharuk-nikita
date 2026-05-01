using Elevate.Entities;

namespace Elevate.Services.Admin;

public interface IAdminUserService
{
    Task<User> CreateUserAsync(
        string login,
        string email,
        string password,
        string firstName,
        string lastName,
        string role,
        CancellationToken ct = default);

    Task<IReadOnlyList<User>> GetAllAsync(CancellationToken ct = default);
    Task<User?> GetByIdAsync(int userId, CancellationToken ct = default);
    Task SetRoleAsync(int userId, string role, CancellationToken ct = default);
    Task SetActiveAsync(int userId, bool isActive, CancellationToken ct = default);
    Task UpdateUserAsync(
        int userId,
        string login,
        string email,
        string firstName,
        string lastName,
        string? newPassword,
        bool clearPasswordPlain,
        CancellationToken ct = default);
    Task DeleteUserAsync(int userId, CancellationToken ct = default);
}
