using System.Security.Claims;
using Elevate.Dtos.Users;

namespace Elevate.Services.Users;

public interface IUserService
{
    Task<UserProfileDto?> GetProfileAsync(int userId, CancellationToken cancellationToken);
    Task<UserProfileDto?> GetProfileAsync(ClaimsPrincipal principal, CancellationToken cancellationToken);
    Task<UserProfileDto?> UpdateProfileAsync(ClaimsPrincipal principal, string firstName, string lastName, string email, CancellationToken ct);
    Task UpdateAvatarAsync(ClaimsPrincipal user, byte[] avatar, CancellationToken ct);
    Task<byte[]?> GetAvatarAsync(ClaimsPrincipal user, CancellationToken ct);
}
