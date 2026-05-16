using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Elevate.Entities;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Elevate.Services.Auth.Tokens;

public sealed class JwtTokenService : IJwtTokenService
{
    private static readonly JwtSecurityTokenHandler TokenHandler = new();

    private readonly JwtOptions _jwtOptions;
    private readonly WebAdministrationOptions _webAdmin;

    public JwtTokenService(
        IOptions<JwtOptions> jwtOptions,
        IOptions<WebAdministrationOptions> webAdministrationOptions)
    {
        _jwtOptions = jwtOptions?.Value ?? throw new ArgumentNullException(nameof(jwtOptions));
        _webAdmin = webAdministrationOptions?.Value ?? throw new ArgumentNullException(nameof(webAdministrationOptions));
        ValidateOptions(_jwtOptions);
    }

    public JwtTokenResult CreateToken(User user)
    {
        ArgumentNullException.ThrowIfNull(user);

        var claims = JwtClaimFactory.CreateClaims(user, _webAdmin.Login);
        var signingCredentials = CreateSigningCredentials(_jwtOptions.SigningKey);
        var expiresAt = DateTime.UtcNow.AddMinutes(_jwtOptions.ExpiresMinutes);

        var tokenDescriptor = new JwtSecurityToken(
            issuer: _jwtOptions.Issuer,
            audience: _jwtOptions.Audience,
            claims: claims,
            expires: expiresAt,
            signingCredentials: signingCredentials);

        var jwt = TokenHandler.WriteToken(tokenDescriptor);

        return new JwtTokenResult(jwt, expiresAt);
    }

    private static void ValidateOptions(JwtOptions options)
    {
        if (string.IsNullOrWhiteSpace(options.SigningKey))
            throw new ArgumentException("JWT signing key must be configured.", nameof(options));

        if (options.ExpiresMinutes <= 0)
            throw new ArgumentException("JWT expiration must be greater than zero.", nameof(options));
    }

    private static SigningCredentials CreateSigningCredentials(string signingKey)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey));
        return new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    }
}
