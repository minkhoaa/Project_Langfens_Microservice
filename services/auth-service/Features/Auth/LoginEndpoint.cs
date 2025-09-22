using auth_service.Application.Auth;
using auth_service.Application.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class LoginEndpoint
{
    public static RouteHandlerBuilder MapLoginEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/login", LoginAsync)
                    .AllowAnonymous()
                    .Produces(StatusCodes.Status200OK)
                    .Produces(StatusCodes.Status400BadRequest);
    }

    private static async Task<IResult> LoginAsync(HttpContext httpContext,
                                                  [FromServices] IAuthService authService,
                                                  [FromServices] ICookieService cookieService,
                                                  [FromBody] LoginDto dto,
                                                  CancellationToken ct)
    {
        var requestContext = RequestContext.FromHttpContext(httpContext);
        var result = await authService.PasswordLoginAsync(dto, requestContext, ct);

        if (result.SessionTicket is SessionTicket ticket)
        {
            var options = cookieService.CreateSessionCookie(ticket.ExpiresAt);
            httpContext.Response.Cookies.Append("sid", ticket.SessionId, options);
        }

        return result.ToHttpResult();
    }
}
