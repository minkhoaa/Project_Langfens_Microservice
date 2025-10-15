using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using auth_service.Application.Common;
using auth_service.Data;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using auth_service.Models;
using Google.Apis.Auth;
using MassTransit;
using Microsoft.AspNetCore.Identity;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Auth_Email;

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
    Task<IResult> ConfirmEmail(string email, string otp, CancellationToken ct);

}

public class AuthService(
    UserManager<User> userManager,
    SignInManager<User> signInManager,
    IJwtTokenFactory jwtTokenFactory,
    IEmailValidator emailValidator,
    ISessionRepository sessionRepository,
    ISessionStore sessionStore,
    IGoogleTokenVerifier googleTokenVerifier,
    IOtpStore redisOtpStore,
    IPublishEndpoint publish,
    ILogger<string> logger,
    IOtpGenerator otpGenerator
    )
    : IAuthService
{
    private const int MaxSessionsPerUser = 5;
    private static readonly TimeSpan SessionLifetime = TimeSpan.FromDays(30);
    private static readonly TimeSpan RotationThreshold = TimeSpan.FromDays(3);
    private static readonly TimeSpan TtlSeconds = TimeSpan.FromSeconds(180);
    private static readonly TimeSpan BlockSeconds = TimeSpan.FromSeconds(300);
    private static readonly TimeSpan TouchCooldowns = TimeSpan.FromSeconds(30);
    private static readonly int MaxAttempts = 5;

    public async Task<AuthOperationResult> RegisterAsync(RegisterDto dto, CancellationToken ct)
    {
        var emailRaw = dto.Email?.Trim();
        var password = dto.Password?.Trim();
        if (string.IsNullOrWhiteSpace(emailRaw) || string.IsNullOrWhiteSpace(password))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email or password is missed", null!),
                StatusCodes.Status400BadRequest);
        } 
        if (!emailValidator.IsValid(emailRaw))
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email format is not valid", null!),
                StatusCodes.Status400BadRequest);
        }

        var email = emailRaw.ToLowerInvariant();
        var existed = await userManager.FindByEmailAsync(email);
        if (existed is not null)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Email is already used", null!),
                StatusCodes.Status400BadRequest);
        }

        var user = new User
        {
            Email = email,
            UserName = email, 
            EmailConfirmed = false
        };

        var result = await userManager.CreateAsync(user, password);
        if (!result.Succeeded)
        {
            var message = result.Errors.Select(x => x.Description).FirstOrDefault() ?? "Unable to create user";
            return AuthOperationResult.Failure(new ApiResultDto(false, message, null!),
                StatusCodes.Status400BadRequest);
        }

        try
        {
            var otp = otpGenerator.Generate();
            await redisOtpStore.PutOtp(email, otp, TtlSeconds);
            await redisOtpStore.TouchResendCooldown(email, TouchCooldowns);
            await publish.Publish(new UserRegisteredSendOtp(email, otp, 60), ct);
            var payload = new { id = user.Id, email = user.Email };
            return AuthOperationResult.Success(new ApiResultDto(true,
                "User is created successfully, check your email for verification", payload));
        }
        catch (Exception e)
        {
            return AuthOperationResult.Failure(
                new ApiResultDto(false, $"Failed to send verification email. Please try again + {e.Message}", null!),
                StatusCodes.Status502BadGateway);        }
    }
    public async Task<IResult> ConfirmEmail(string email, string otp, CancellationToken ct)
    {
        var existedUser = await userManager.FindByEmailAsync(email);
        logger.LogInformation($"Verifying {email}");

        if (existedUser == null)
        {
            return Results.NotFound(new ApiResultDto(false, "Not found user", null!));
        }

        var result = await redisOtpStore.Verify(email, otp, MaxAttempts, BlockSeconds);
        if (!result)
            return Results.BadRequest(new ApiResultDto(false, "Otp is incorrect or expired", null!));    
        existedUser.EmailConfirmed = true;
        var update = await userManager.UpdateAsync(existedUser);
        if (!update.Succeeded)
        {
            var msg = update.Errors.Select(x => x.Description).FirstOrDefault() ?? "Unable to update user";
            return Results.Problem(update.Errors.ToString());
        }
        return Results.Ok(new ApiResultDto(true, $"Verified user {email} successfully", null!));
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

        var user = await userManager.FindByEmailAsync(email);
        if (user is null)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "User is not existed", null!),
                StatusCodes.Status400BadRequest);
        }

        var check = await signInManager.CheckPasswordSignInAsync(user, password, true);
        if (!check.Succeeded)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "Password is incorrect", null!),
                StatusCodes.Status400BadRequest);
        }

        var roles = await userManager.GetRolesAsync(user);
        var accessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, ct);

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
            payload = await googleTokenVerifier.VerifyAsync(request.IdToken, ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Failed to verify Google idToken");
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

        var user = await userManager.FindByLoginAsync(loginProvider, providerKey);
        if (user is null)
        {
            user = await userManager.FindByEmailAsync(payload.Email);
            if (user is null)
            {
                user = new User
                {
                    Email = payload.Email,
                    UserName = payload.Email,
                    EmailConfirmed = true
                };

                var createUser = await userManager.CreateAsync(user);
                if (!createUser.Succeeded)
                {
                    var message = createUser.Errors.FirstOrDefault()?.Description ?? "Unable to create user";
                    return AuthOperationResult.Failure(new ApiResultDto(false, message, null!),
                        StatusCodes.Status400BadRequest);
                }
            }

            var info = new UserLoginInfo(loginProvider, providerKey, "Google");
            var addLogin = await userManager.AddLoginAsync(user, info);
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

        var roles = await userManager.GetRolesAsync(user);
        var accessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, ct);
        var sessionTicket = await CreateOrUpdateSessionAsync(user, context, ct);
        return AuthOperationResult.Success(new ApiResultDto(true, "Login successfully", accessToken), sessionTicket);
    }

    public async Task<AuthOperationResult> RefreshAsync(RequestContext context, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(context.SessionId))
        {
            return AuthOperationResult.Unauthorized();
        }

        var session = await sessionStore.GetSessionAsync(context.SessionId, ct);
        if (session is null || session.Exp <= DateTime.UtcNow)
        {
            return AuthOperationResult.Unauthorized();
        }

        var user = await userManager.FindByIdAsync(session.UserId);
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

        var dbSession = await sessionRepository.FindAsync(user.Id, deviceId!, ct);
        if (dbSession is null || dbSession.RevokedAt is not null || dbSession.Jti != session.Jti ||
            dbSession.Exp <= DateTime.UtcNow)
        {
            return AuthOperationResult.Unauthorized();
        }

        var roles = await userManager.GetRolesAsync(user);
        var newAccessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, ct);

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

            await sessionStore.StoreSessionAsync(updatedSession, SessionLifetime, ct);
            await sessionStore.SetDeviceSessionAsync(updatedSession, SessionLifetime, ct);
        }
        else
        {
            dbSession.LastSeen = now;
            await sessionStore.RefreshSessionTtlAsync(session.Sid, SessionLifetime, ct);
        }

        await sessionRepository.SaveChangesAsync(ct);
        return AuthOperationResult.Success(new ApiResultDto(true, "Success", newAccessToken));
    }

    public async Task<AuthOperationResult> LogoutAsync(RequestContext context, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(context.SessionId))
        {
            var payload = new ApiResultDto(true, "Logout successfully", null!);
            return AuthOperationResult.Success(payload).WithClearCookie();
        }

        var session = await sessionStore.GetSessionAsync(context.SessionId, ct);
        if (session is not null)
        {
            if (!string.IsNullOrWhiteSpace(session.DeviceId))
            {
                var dbSession = await sessionRepository.FindAsync(session.UserId, session.DeviceId!, ct);
                if (dbSession is not null)
                {
                    dbSession.RevokedAt = DateTime.UtcNow;
                }
            }

            await sessionStore.RemoveSessionAsync(session, ct);
            await sessionRepository.SaveChangesAsync(ct);
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

        await sessionRepository.UpsertAsync(sessionEntity, ct);
        await sessionRepository.SaveChangesAsync(ct);

        var sessionRecord =
            new SessionRecord(sid, user.Id, jti, expiration, deviceId, context.UserAgent, context.IpAddress);
        await sessionStore.StoreSessionAsync(sessionRecord, SessionLifetime, ct);
        await sessionStore.SetDeviceSessionAsync(sessionRecord, SessionLifetime, ct);
        await sessionStore.EnsureSessionLimitAsync(user.Id, MaxSessionsPerUser, ct);

        return new SessionTicket(sessionRecord.Sid, new DateTimeOffset(expiration, TimeSpan.Zero));
    }

    private static string NormalizeDeviceId(string? deviceId)
    {
        return string.IsNullOrWhiteSpace(deviceId) ? Guid.NewGuid().ToString("N") : deviceId!;
    }

    private static string GenerateIdentifier() => Guid.NewGuid().ToString("N");
}