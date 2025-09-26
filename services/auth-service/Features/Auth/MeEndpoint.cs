using System.Security.Claims;
using auth_service.Application.Auth;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class MeEndpoint
{
    public static RouteHandlerBuilder MapMeEndpoint(this RouteGroupBuilder group)
    {
        return group.MapGet("/me", MeAsync)
            .RequireAuthorization()
            .Produces(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status401Unauthorized);
    }

    private static async Task<IResult> MeAsync(ClaimsPrincipal principal,
        [FromServices] IAuthService authService)
    {
        var result = await authService.GetCurrentUserAsync(principal);
        return result.ToHttpResult();
    }
}