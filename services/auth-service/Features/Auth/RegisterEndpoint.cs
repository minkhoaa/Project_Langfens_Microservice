using auth_service.Application.Auth;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class RegisterEndpoint
{
    public static RouteHandlerBuilder MapRegisterEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/register", RegisterAsync)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder MapEmailConfirmEndpoint(this RouteGroupBuilder group)
    {
        return group.MapGet("/verify", ConfirmEmail)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder MapResendOtpEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/resend-otp", ResendEmailHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder MapForgotPasswordEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/forgot-password", ForgotPasswordHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder MapResendForgotPasswordEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/resend-otp-reset-password", ResendForgotPasswordHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder MapConfirmForgotPasswordEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/confirm-otp-reset-password", ConfirmForgotPasswordHandler)
            .AllowAnonymous()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status400BadRequest);
    }
    private static async Task<IResult> RegisterAsync([FromServices] IAuthService authService,
        [FromBody] RegisterDto dto,
        CancellationToken ct)
    {
        var result = await authService.RegisterAsync(dto, ct);
        return result.ToHttpResult();
    }
    private static async Task<IResult> ConfirmEmail([FromServices] IAuthService authService,
        [FromQuery] string email,
        [FromQuery] string otp,
        CancellationToken ct)
    {
        var result = await authService.ConfirmEmail(email, otp, ct);
        return result;
    }
    private static async Task<IResult> ResendEmailHandler([FromServices] IAuthService authService,
        [FromQuery] string email,
        CancellationToken ct)
    {
        var result = await authService.ResendEmail(email, ct);
        return result;
    }
    private static async Task<IResult> ForgotPasswordHandler([FromServices] IAuthService authService,
        [FromQuery] string email,
        CancellationToken ct)
    {
        var result = await authService.ForgotPasswordRequestAsync(email, ct);
        return result;
    }
    private static async Task<IResult> ResendForgotPasswordHandler([FromServices] IAuthService authService,
        [FromQuery] string email,
        CancellationToken ct)
    {
        var result = await authService.ResendForgotPasswordAsync(email, ct);
        return result;
    }
    private static async Task<IResult> ConfirmForgotPasswordHandler([FromServices] IAuthService authService,
        [FromQuery] string email,
        string otp,
        string newPassword,
        CancellationToken ct)
    {
        var result = await authService.ConfirmResetPasswordAsync(email,otp, newPassword, ct);
        return result;
    }
    
}