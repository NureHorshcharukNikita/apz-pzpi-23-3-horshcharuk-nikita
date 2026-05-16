using Elevate.Dtos.Auth;
using Elevate.Entities;
using Elevate.Mappings.Auth;
using Elevate.Services.Auth.Tokens;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace Elevate.Services.Auth.Core;

public class AuthService : IAuthService
{
    private readonly UserRepository _userRepository;
    private readonly UserValidator _userValidator;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IPasswordHasher<User> _passwordHasher;
    private readonly WebAdministrationOptions _webAdmin;

    public AuthService(
        UserRepository userRepository,
        UserValidator userValidator,
        IJwtTokenService jwtTokenService,
        IPasswordHasher<User> passwordHasher,
        IOptions<WebAdministrationOptions> webAdministrationOptions)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _userValidator = userValidator ?? throw new ArgumentNullException(nameof(userValidator));
        _jwtTokenService = jwtTokenService ?? throw new ArgumentNullException(nameof(jwtTokenService));
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _webAdmin = webAdministrationOptions?.Value ?? throw new ArgumentNullException(nameof(webAdministrationOptions));
    }

    public async Task<LoginResponseDto> LoginAsync(
        LoginRequestDto request,
        CancellationToken cancellationToken)
    {
        var user = await _userRepository.FindByLoginOrEmailAsync(request.LoginOrEmail, cancellationToken);
        _userValidator.ValidatePassword(user, request.Password);

        var tokenResult = _jwtTokenService.CreateToken(user);
        await _userRepository.UpdateLastLoginAsync(user, cancellationToken);

        return AuthMappings.ToLoginResponseDto(user, tokenResult);
    }

    public async Task<LoginResponseDto> RegisterAsync(
        RegisterRequestDto request,
        CancellationToken cancellationToken)
    {
        var exists = await _userRepository.ExistsByLoginOrEmailAsync(
            request.Login,
            request.Email,
            cancellationToken);

        if (exists)
        {
            throw new InvalidOperationException(
                "A user with this login or email already exists.");
        }

        if (string.Equals(
                request.Login.Trim(),
                _webAdmin.Login.Trim(),
                StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("This login is reserved for the system web administrator.");
        }

        var user = CreateUserEntity(request);
        user.PasswordHash = _passwordHasher.HashPassword(user, request.Password);

        await _userRepository.AddUserAsync(user, cancellationToken);

        var tokenResult = _jwtTokenService.CreateToken(user);
        return AuthMappings.ToLoginResponseDto(user, tokenResult);
    }

    private static User CreateUserEntity(RegisterRequestDto request)
    {
        return new User
        {
            Login = request.Login.Trim(),
            Email = request.Email.Trim(),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Role = "User",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
    }
}
