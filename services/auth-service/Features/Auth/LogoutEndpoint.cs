using auth_service.Application.Auth;
using auth_service.Application.Common;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class LogoutEndpoint
{
    public static RouteHandlerBuilder MapLogoutEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/logout", LogoutAsync)
            .Produces(StatusCodes.Status200OK);
    }

    private static async Task<IResult> LogoutAsync(HttpContext httpContext,
        [FromServices] IAuthService authService,
        [FromServices] ICookieService cookieService,
        CancellationToken ct)
    {
        var requestContext = RequestContext.FromHttpContext(httpContext);
        var result = await authService.LogoutAsync(requestContext, ct);

        if (result.ShouldClearSessionCookie)
        {
            var options = cookieService.CreateRemovalCookie();
            httpContext.Response.Cookies.Append("sid", string.Empty, options);
        }

        return result.ToHttpResult();
    }
}