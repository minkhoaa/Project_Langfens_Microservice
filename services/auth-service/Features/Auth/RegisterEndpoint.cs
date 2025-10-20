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
}