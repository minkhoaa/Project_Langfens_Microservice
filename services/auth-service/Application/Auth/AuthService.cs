using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using auth_service.Application.Common;
using auth_service.Data;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using auth_service.Models;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Identity;
using Shared.Contracts.Contracts;

namespace auth_service.Application.Auth;

public interface IAuthService
{
    Task<AuthOperationResult> RegisterAsync(RegisterDto dto, CancellationToken ct);
    Task<AuthOperationResult> PasswordLoginAsync(LoginDto dto, RequestContext context, CancellationToken ct);

    Task<AuthOperationResult>
        GoogleLoginAsync(GoogleLoginRequest request, RequestContext context, CancellationToken ct);

    Task<AuthOperationResult> RefreshAsync(RequestContext context, CancellationToken ct);
    Task<AuthOperationResult> LogoutAsync(RequestContext context, CancellationToken ct);
    Task<AuthOperationResult> GetCurrentUserAsync(ClaimsPrincipal principal);
}

public class AuthService : IAuthService
{
    private const int MaxSessionsPerUser = 5;
    private static readonly TimeSpan SessionLifetime = TimeSpan.FromDays(30);
    private static readonly TimeSpan RotationThreshold = TimeSpan.FromDays(3);
    private readonly IEmailValidator _emailValidator;
    private readonly IGoogleTokenVerifier _googleTokenVerifier;
    private readonly IJwtTokenFactory _jwtTokenFactory;
    private readonly ILogger<AuthService> _logger;
    private readonly ISessionRepository _sessionRepository;
    private readonly ISessionStore _sessionStore;
    private readonly SignInManager<User> _signInManager;

    private readonly UserManager<User> _userManager;

    public AuthService(UserManager<User> userManager,
        SignInManager<User> signInManager,
        IJwtTokenFactory jwtTokenFactory,
        IEmailValidator emailValidator,
        ISessionRepository sessionRepository,
        ISessionStore sessionStore,
        IGoogleTokenVerifier googleTokenVerifier,
        ILogger<AuthService> logger)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _jwtTokenFactory = jwtTokenFactory;
        _emailValidator = emailValidator;
        _sessionRepository = sessionRepository;
        _sessionStore = sessionStore;
        _googleTokenVerifier = googleTokenVerifier;
        _logger = logger;
    }

    public async Task<AuthOperationResult> RegisterAsync(RegisterDto dto, CancellationToken ct)
    {
        var email = dto.Email?.Trim();
        var password = dto.Password?.Trim();
        if (!_emailValidator.IsValid(email))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email format is not valid", null!),
                StatusCodes.Status400BadRequest);
        }

        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email or password is missed", null!),
                StatusCodes.Status400BadRequest);
        }

        var existed = await _userManager.FindByEmailAsync(email);
        if (existed is not null)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email is used", null!),
                StatusCodes.Status400BadRequest);
        }

        var user = new User
        {
            Email = email,
            UserName = password
        };

        var result = await _userManager.CreateAsync(user, password);
        if (!result.Succeeded)
        {
            var message = result.Errors.Select(x => x.Description).FirstOrDefault() ?? "Unable to create user";
            return AuthOperationResult.Failure(new ApiResultDto(false, message, null!),
                StatusCodes.Status400BadRequest);
        }

        var payload = new { id = user.Id, email = user.Email };
        return AuthOperationResult.Success(new ApiResultDto(true, "User is created successfully", payload));
    }

    public async Task<AuthOperationResult> PasswordLoginAsync(LoginDto dto, RequestContext context,
        CancellationToken ct)
    {
        var email = dto.Email?.Trim();
        var password = dto.Password?.Trim();
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email or password is missing", null!),
                StatusCodes.Status400BadRequest);
        }

        var user = await _userManager.FindByEmailAsync(email);
        if (user is null)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "User is not existed", null!),
                StatusCodes.Status400BadRequest);
        }

        var check = await _signInManager.CheckPasswordSignInAsync(user, password, true);
        if (!check.Succeeded)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Password is incorrect", null!),
                StatusCodes.Status400BadRequest);
        }

        var roles = await _userManager.GetRolesAsync(user);
        var accessToken = await _jwtTokenFactory.CreateTokenAsync(user, roles, ct);

        var sessionTicket = await CreateOrUpdateSessionAsync(user, context, ct);
        return AuthOperationResult.Success(new ApiResultDto(true, "Login successfully", accessToken), sessionTicket);
    }

    public async Task<AuthOperationResult> GoogleLoginAsync(GoogleLoginRequest request, RequestContext context,
        CancellationToken ct)
    {
        if (request.IdToken is null || string.IsNullOrWhiteSpace(request.IdToken))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Missing Token", null!),
                StatusCodes.Status400BadRequest);
        }

        GoogleJsonWebSignature.Payload payload;
        try
        {
            payload = await _googleTokenVerifier.VerifyAsync(request.IdToken, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to verify Google idToken");
            return AuthOperationResult.Failure(new ApiResultDto(false, ex.Message, null!),
                StatusCodes.Status400BadRequest);
        }

        if (!payload.EmailVerified)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email is not verified by Google", null!),
                StatusCodes.Status400BadRequest);
        }

        const string loginProvider = "Google";
        var providerKey = payload.Subject;

        var user = await _userManager.FindByLoginAsync(loginProvider, providerKey);
        if (user is null)
        {
            user = await _userManager.FindByEmailAsync(payload.Email);
            if (user is null)
            {
                user = new User
                {
                    Email = payload.Email,
                    UserName = payload.Email,
                    EmailConfirmed = true
                };

                var createUser = await _userManager.CreateAsync(user);
                if (!createUser.Succeeded)
                {
                    var message = createUser.Errors.FirstOrDefault()?.Description ?? "Unable to create user";
                    return AuthOperationResult.Failure(new ApiResultDto(false, message, null!),
                        StatusCodes.Status400BadRequest);
                }
            }

            var info = new UserLoginInfo(loginProvider, providerKey, "Google");
            var addLogin = await _userManager.AddLoginAsync(user, info);
            if (!addLogin.Succeeded)
            {
                var alreadyAssociated = addLogin.Errors.Any(e =>
                    e.Code.Contains("LoginAlreadyAssociated", StringComparison.OrdinalIgnoreCase));
                if (!alreadyAssociated)
                {
                    var message = string.Join("; ", addLogin.Errors.Select(e => e.Description));
                    return AuthOperationResult.Failure(new ApiResultDto(false, message, null!),
                        StatusCodes.Status400BadRequest);
                }
            }
        }

        var roles = await _userManager.GetRolesAsync(user);
        var accessToken = await _jwtTokenFactory.CreateTokenAsync(user, roles, ct);
        var sessionTicket = await CreateOrUpdateSessionAsync(user, context, ct);
        return AuthOperationResult.Success(new ApiResultDto(true, "Login successfully", accessToken), sessionTicket);
    }

    public async Task<AuthOperationResult> RefreshAsync(RequestContext context, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(context.SessionId))
        {
            return AuthOperationResult.Unauthorized();
        }

        var session = await _sessionStore.GetSessionAsync(context.SessionId, ct);
        if (session is null || session.Exp <= DateTime.UtcNow)
        {
            return AuthOperationResult.Unauthorized();
        }

        var user = await _userManager.FindByIdAsync(session.UserId);
        if (user is null)
        {
            return AuthOperationResult.Unauthorized();
        }

        var deviceId = !string.IsNullOrWhiteSpace(session.DeviceId)
            ? session.DeviceId
            : !string.IsNullOrWhiteSpace(context.DeviceId)
                ? context.DeviceId
                : null;

        if (string.IsNullOrWhiteSpace(deviceId))
        {
            return AuthOperationResult.Unauthorized();
        }

        var dbSession = await _sessionRepository.FindAsync(user.Id, deviceId!, ct);
        if (dbSession is null || dbSession.RevokedAt is not null || dbSession.Jti != session.Jti ||
            dbSession.Exp <= DateTime.UtcNow)
        {
            return AuthOperationResult.Unauthorized();
        }

        var roles = await _userManager.GetRolesAsync(user);
        var newAccessToken = await _jwtTokenFactory.CreateTokenAsync(user, roles, ct);

        var now = DateTime.UtcNow;
        var rotate = dbSession.Exp - now < RotationThreshold;
        if (rotate)
        {
            var newJti = GenerateIdentifier();
            var newExp = now.Add(SessionLifetime);

            dbSession.PrevJti = dbSession.Jti;
            dbSession.Jti = newJti;
            dbSession.Exp = newExp;
            dbSession.LastSeen = now;
            dbSession.RevokedAt = null;
            dbSession.Ua = context.UserAgent ?? dbSession.Ua;
            dbSession.Ip = context.IpAddress ?? dbSession.Ip;

            var updatedSession = session with
            {
                Jti = newJti,
                Exp = newExp,
                Ua = context.UserAgent ?? session.Ua,
                Ip = context.IpAddress ?? session.Ip
            };

            await _sessionStore.StoreSessionAsync(updatedSession, SessionLifetime, ct);
            await _sessionStore.SetDeviceSessionAsync(updatedSession, SessionLifetime, ct);
        }
        else
        {
            dbSession.LastSeen = now;
            await _sessionStore.RefreshSessionTtlAsync(session.Sid, SessionLifetime, ct);
        }

        await _sessionRepository.SaveChangesAsync(ct);
        return AuthOperationResult.Success(new ApiResultDto(true, "Success", newAccessToken));
    }

    public async Task<AuthOperationResult> LogoutAsync(RequestContext context, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(context.SessionId))
        {
            var payload = new ApiResultDto(true, "Logout successfully", null!);
            return AuthOperationResult.Success(payload).WithClearCookie();
        }

        var session = await _sessionStore.GetSessionAsync(context.SessionId, ct);
        if (session is not null)
        {
            if (!string.IsNullOrWhiteSpace(session.DeviceId))
            {
                var dbSession = await _sessionRepository.FindAsync(session.UserId, session.DeviceId!, ct);
                if (dbSession is not null)
                {
                    dbSession.RevokedAt = DateTime.UtcNow;
                }
            }

            await _sessionStore.RemoveSessionAsync(session, ct);
            await _sessionRepository.SaveChangesAsync(ct);
        }

        var result = new ApiResultDto(true, "Logout successfully", null!);
        return AuthOperationResult.Success(result).WithClearCookie();
    }

    public Task<AuthOperationResult> GetCurrentUserAsync(ClaimsPrincipal principal)
    {
        if (principal.Identity is null || !principal.Identity.IsAuthenticated)
        {
            return Task.FromResult(AuthOperationResult.Unauthorized());
        }

        var email = principal.FindFirstValue(ClaimTypes.Email) ??
                    principal.FindFirstValue(JwtRegisteredClaimNames.Email);

        if (string.IsNullOrWhiteSpace(email))
        {
            return Task.FromResult(AuthOperationResult.Failure(new ApiResultDto(false, "Email is not exist", null!),
                StatusCodes.Status404NotFound));
        }

        var id = principal.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
        var payload = new ApiResultDto(true, "Get information successfully", new { id, email });
        return Task.FromResult(AuthOperationResult.Success(payload));
    }

    private async Task<SessionTicket> CreateOrUpdateSessionAsync(User user, RequestContext context,
        CancellationToken ct)
    {
        var deviceId = NormalizeDeviceId(context.DeviceId);
        var now = DateTime.UtcNow;
        var expiration = now.Add(SessionLifetime);
        var jti = GenerateIdentifier();
        var sid = GenerateIdentifier();

        var sessionEntity = new SessionEntity
        {
            UserId = user.Id,
            DeviceId = deviceId,
            Jti = jti,
            Exp = expiration,
            LastSeen = now,
            Ua = context.UserAgent,
            Ip = context.IpAddress,
            PrevJti = null,
            RevokedAt = null
        };

        await _sessionRepository.UpsertAsync(sessionEntity, ct);
        await _sessionRepository.SaveChangesAsync(ct);

        var sessionRecord =
            new SessionRecord(sid, user.Id, jti, expiration, deviceId, context.UserAgent, context.IpAddress);
        await _sessionStore.StoreSessionAsync(sessionRecord, SessionLifetime, ct);
        await _sessionStore.SetDeviceSessionAsync(sessionRecord, SessionLifetime, ct);
        await _sessionStore.EnsureSessionLimitAsync(user.Id, MaxSessionsPerUser, ct);

        return new SessionTicket(sessionRecord.Sid, new DateTimeOffset(expiration, TimeSpan.Zero));
    }

    private static string NormalizeDeviceId(string? deviceId)
    {
        return string.IsNullOrWhiteSpace(deviceId) ? Guid.NewGuid().ToString("N") : deviceId!;
    }

    private static string GenerateIdentifier() => Guid.NewGuid().ToString("N");
}