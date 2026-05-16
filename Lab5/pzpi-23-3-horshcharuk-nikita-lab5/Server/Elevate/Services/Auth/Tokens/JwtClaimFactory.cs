using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Elevate.Entities;

namespace Elevate.Services.Auth.Tokens;

public static class JwtClaimFactory
{
    private const string DefaultRole = "User";

    public const string ElevateWebAdminClaimType = "elevate_web_admin";

    public static bool IsElevateWebPortalAdministrator(User user, string configuredWebAdminLogin)
    {
        if (user is null)
        {
            return false;
        }

        var role = string.IsNullOrWhiteSpace(user.Role) ? DefaultRole : user.Role;
        if (string.Equals(role, UserRoleNames.SystemAdministrator, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (string.IsNullOrWhiteSpace(configuredWebAdminLogin))
        {
            return false;
        }

        if (!string.Equals(role, UserRoleNames.Admin, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        return string.Equals(
            NormalizeLogin(user.Login),
            NormalizeLogin(configuredWebAdminLogin),
            StringComparison.OrdinalIgnoreCase);
    }

    public static IEnumerable<Claim> CreateClaims(User user, string configuredWebAdminLogin)
    {
        var userId = user.UserID.ToString();
        var role = string.IsNullOrWhiteSpace(user.Role) ? DefaultRole : user.Role;

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId),
            new(ClaimTypes.NameIdentifier, userId),
            new(JwtRegisteredClaimNames.UniqueName, user.Login),
            new(ClaimTypes.Role, role)
        };

        if (IsElevateWebPortalAdministrator(user, configuredWebAdminLogin))
        {
            claims.Add(new Claim(ElevateWebAdminClaimType, "true"));
        }

        return claims;
    }

    private static string NormalizeLogin(string login) => login.Trim();
}
