using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using auth_service.Application.Common;
using auth_service.Data;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using Google.Apis.Auth;
using MassTransit;
using MassTransit.Initializers;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Auth_Email;
using Shared.Security.Claims;
using Shared.Security.Roles;
using Shared.Security.Scopes;

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
    Task<IResult> ResendEmail(string toEmail, CancellationToken token);
    Task<IResult> ForgotPasswordRequestAsync(string email, CancellationToken ct);
    Task<IResult> ResendForgotPasswordAsync(string email, CancellationToken ct);
    Task<IResult> ConfirmResetPasswordAsync(string email, string otp, string newPassword, CancellationToken ct);
    Task<IResult> GetAllUsersAsync(CancellationToken ct);


}

public class AuthService(
    UserManager<User> userManager,
    RoleManager<Role> roleManager,
    SignInManager<User> signInManager,
    IJwtTokenFactory jwtTokenFactory,
    IEmailValidator emailValidator,
    ISessionRepository sessionRepository,
    ISessionStore sessionStore,
    IGoogleTokenVerifier googleTokenVerifier,
    IOtpStore redisOtpStore,
    IPublishEndpoint publish,
    ILogger<string> logger,
    IOtpGenerator otpGenerator,
    IOptions<JwtSettings> jwtSetttings,
    AuthDbContext dbContext)
    : IAuthService
{
    private JwtSettings _jwtSettings = jwtSetttings.Value;

    private const int MaxSessionsPerUser = 5;
    private static readonly TimeSpan SessionLifetime = TimeSpan.FromDays(30);
    private static readonly TimeSpan RotationThreshold = TimeSpan.FromDays(3);
    private static readonly TimeSpan TtlSeconds = TimeSpan.FromSeconds(180);
    private static readonly TimeSpan BlockSeconds = TimeSpan.FromSeconds(300);
    private static readonly TimeSpan TouchCooldowns = TimeSpan.FromSeconds(30);
    private static readonly int MaxAttempts = 5;
    private static readonly TimeSpan OtpTtl = TimeSpan.FromMinutes(3);
    private static readonly TimeSpan ResendCooldown = TimeSpan.FromSeconds(30);

    private static readonly TimeSpan PwResetTtl = TimeSpan.FromMinutes(10);
    private static readonly TimeSpan PwResetCooldown = TimeSpan.FromSeconds(30);
    private const int PwResetMaxAttempts = 5;
    private static readonly TimeSpan PwResetBlock = TimeSpan.FromMinutes(5);

    private static string PwResetKey(string email) => $"pwreset::{email}";


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

        if (!await roleManager.RoleExistsAsync(Roles.User))
        {
            await roleManager.CreateAsync(new Role { Name = Roles.User });
        }

        if (!await userManager.IsInRoleAsync(user, Roles.User))
        {
            await userManager.AddToRoleAsync(user, Roles.User);
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
                StatusCodes.Status502BadGateway);
        }
    }
    public async Task<IResult> ResendEmail(string toEmail, CancellationToken token)
    {
        var email = toEmail?.Trim().ToLowerInvariant();
        if (string.IsNullOrEmpty(email))
            return Results.BadRequest(new ApiResultDto(false, "Email is missing", null!));
        var user = await userManager.FindByEmailAsync(email);
        if (user == null)
            return Results.Ok(new ApiResultDto(true, "Verification code was sent", null!));

        if (user.EmailConfirmed)
            return Results.Conflict(new ApiResultDto(false, "Email is verified", null!));
        if (!await redisOtpStore.CanResend(email, ResendCooldown))
        {
            var remaining = await redisOtpStore.GetResendCooldownRemaining(email);
            var secs = Math.Max(1, (int)Math.Ceiling(remaining.TotalSeconds));
            return Results.BadRequest(new ApiResultDto(false, $"Please wait {secs}s before retrying",
                new { retryAfter = secs }));
        }

        var newOtp = otpGenerator.Generate();
        await redisOtpStore.PutOtp(email, newOtp, OtpTtl);
        await redisOtpStore.TouchResendCooldown(email, TouchCooldowns);
        await publish.Publish(new UserRegisteredSendOtp(email, newOtp, (long)OtpTtl.TotalSeconds), token);
        return Results.Ok(new ApiResultDto(true, "Resend otp successfully", null!));

    }

    public async Task<IResult> ForgotPasswordRequestAsync(string email, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(email))
            return Results.BadRequest(new ApiResultDto(false, "Email is required", null!));
        email = email.Trim().ToLowerInvariant();

        var user = await userManager.FindByEmailAsync(email);
        if (user == null || !user.EmailConfirmed)
            return Results.Ok(new ApiResultDto(true, "If the email exists, we've sent reset instructions", null!));

        var key = PwResetKey(email);
        if (!await redisOtpStore.CanResend(key, PwResetCooldown))
            return Results.BadRequest(
                new ApiResultDto(false, "Too many requests", new { retryAfter = (int)PwResetCooldown.TotalSeconds }));

        var otp = otpGenerator.Generate();
        await redisOtpStore.PutOtp(key, otp, PwResetTtl);
        await redisOtpStore.TouchResendCooldown(key, PwResetCooldown);
        await publish.Publish(new UserRegisteredSendOtp(email, otp, (long)PwResetTtl.TotalSeconds), ct);

        return Results.Ok(new ApiResultDto(true, "If the email exists, we've sent reset instructions", null!));
    }

    public async Task<IResult> ResendForgotPasswordAsync(string email, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(email))
            return Results.BadRequest(new ApiResultDto(false, "Email is required", null!));
        email = email.Trim().ToLowerInvariant();

        var user = await userManager.FindByEmailAsync(email);
        if (user == null || !user.EmailConfirmed)
            return Results.Ok(new ApiResultDto(true, "If the email exists, we've re-sent the reset email", null!));

        var key = PwResetKey(email);

        if (!await redisOtpStore.CanResend(key, PwResetCooldown))
            return Results.BadRequest(
                new ApiResultDto(false, "Too many requests", new { retryAfter = (int)PwResetCooldown.TotalSeconds }));

        var otp = otpGenerator.Generate();
        await redisOtpStore.PutOtp(key, otp, PwResetTtl);
        await redisOtpStore.TouchResendCooldown(key, PwResetCooldown);

        await publish.Publish(new UserRegisteredSendOtp(email, otp, (long)PwResetTtl.TotalSeconds), ct);
        return Results.Ok(new ApiResultDto(true, "If the email exists, we've re-sent the reset email", null!));
    }

    public async Task<IResult> ConfirmResetPasswordAsync(string email, string otp, string newPassword, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(otp) || string.IsNullOrWhiteSpace(newPassword))
            return Results.BadRequest(new ApiResultDto(false, "Parameters are missing", null!));
        email = email.Trim().ToLowerInvariant();

        var user = await userManager.FindByEmailAsync(email);
        if (user == null)
            return Results.BadRequest(new ApiResultDto(false, "OTP is invalid or expired", null!));

        var key = PwResetKey(email);
        var ok = await redisOtpStore.Verify(key, otp, MaxAttempts, BlockSeconds);
        if (!ok)
            return Results.BadRequest(new ApiResultDto(false, "OTP is invalid or expired", null!));

        var token = await userManager.GeneratePasswordResetTokenAsync(user);
        var res = await userManager.ResetPasswordAsync(user, token, newPassword);

        await redisOtpStore.Clear(key);

        if (!res.Succeeded)
        {
            var msg = string.Join("; ", res.Errors.Select(e => e.Description));
            return Results.BadRequest(new ApiResultDto(false, msg, null!));
        }
        return Results.Ok(new ApiResultDto(true, "Reset password successfully", null!));
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
            return Results.Problem(update.Errors.ToString() ?? msg);
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
        var userScopes = new List<string>();
        foreach (var role in roles)
        {
            if (RoleBasedScopeProvider.CustomRoleOptions.TryGetValue(role, out var scopes))
            {
                userScopes.AddRange(scopes);
            }
        }
        var sessionTicket = await CreateOrUpdateSessionAsync(user, context, ct);
        var accessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, userScopes, sessionTicket.SessionId, ct);
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
                if (!await roleManager.RoleExistsAsync(Roles.User))
                {
                    await roleManager.CreateAsync(new Role { Name = Roles.User });
                }

                if (!await userManager.IsInRoleAsync(user, Roles.User))
                {
                    await userManager.AddToRoleAsync(user, Roles.User);
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
        var userScopes = new List<string>();
        foreach (var role in roles)
        {
            if (RoleBasedScopeProvider.CustomRoleOptions.TryGetValue(role, out var scopes))
            {
                userScopes.AddRange(scopes);
            }
        }
        var sessionTicket = await CreateOrUpdateSessionAsync(user, context, ct);
        var accessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, userScopes.Distinct(), sessionTicket.SessionId, ct);
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

        var dbSession = await sessionRepository.FindAsync(user.Id, deviceId, ct);
        if (dbSession is null || dbSession.RevokedAt is not null || dbSession.Jti != session.Jti ||
            dbSession.Exp <= DateTime.UtcNow)
        {
            return AuthOperationResult.Unauthorized();
        }

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
        var roles = await userManager.GetRolesAsync(user);
        var userScopes = new List<string>();
        foreach (var role in roles)
        {
            if (RoleBasedScopeProvider.CustomRoleOptions.TryGetValue(role, out var scopes))
            {
                userScopes.AddRange(scopes);
            }
        }
        var newAccessToken = await jwtTokenFactory.CreateTokenAsync(user, roles, userScopes.Distinct(), session.Sid, ct);

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

    public async Task<AuthOperationResult> GetCurrentUserAsync(ClaimsPrincipal principal)
    {
        if (principal.Identity is null || !principal.Identity.IsAuthenticated)
        {
            return AuthOperationResult.Unauthorized();
        }

        var sub = principal.FindFirst(CustomClaims.Sub)?.Value;
        if (sub is null)
        {
            return AuthOperationResult.Unauthorized();
        }

        var user = await userManager.FindByIdAsync(sub);
        if (user is null)
        {
            return AuthOperationResult.Failure(new ApiResultDto(false, "User not found", null), StatusCodes.Status404NotFound);
        }

        var roles = await userManager.GetRolesAsync(user);
        var payload = new ApiResultDto(true, "Get information successfully", new
        {
            id = sub,
            user.Email,
            emailConfirmed = user.EmailConfirmed,
            roles
        });
        return AuthOperationResult.Success(payload);
    }

    public async Task<IResult> GetAllUsersAsync(CancellationToken ct)
    {
        var users = await dbContext.Users
            .AsNoTracking()
            .Select(u => new { u.Id, u.Email, u.EmailConfirmed })
            .ToListAsync(ct);

        var rolePairs = await dbContext.UserRoles
            .AsNoTracking()
            .Join(dbContext.Roles.AsNoTracking(), ur => ur.RoleId, r => r.Id,
                (ur, r) => new { ur.UserId, RoleName = r.Name })
            .ToListAsync(ct);

        var rolesLookup = rolePairs
            .GroupBy(x => x.UserId)
            .ToDictionary(
                g => g.Key,
                g => g.Select(x => x.RoleName ?? string.Empty)
                    .Where(name => !string.IsNullOrWhiteSpace(name))
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToArray());

        var payload = users
            .Select(u =>
            {
                rolesLookup.TryGetValue(u.Id, out var roleNames);
                return new UserSummaryDto(u.Id, u.Email ?? string.Empty, u.EmailConfirmed, roleNames ?? Array.Empty<string>());
            })
            .ToList();

        return Results.Ok(new ApiResultDto(true, "Get users successfully", payload));
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
