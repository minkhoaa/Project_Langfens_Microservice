using auth_service.Application.Auth;
using auth_service.Application.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class LoginGoogleEndpoint
{
    public static RouteHandlerBuilder MapGoogleLoginEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/login-google", LoginGoogleAsync)
                    .AllowAnonymous()
                    .Produces(StatusCodes.Status200OK)
                    .Produces(StatusCodes.Status400BadRequest);
    }

    private static async Task<IResult> LoginGoogleAsync(HttpContext httpContext,
                                                        [FromServices] IAuthService authService,
                                                        [FromServices] ICookieService cookieService,
                                                        [FromBody] GoogleLoginRequest request,
                                                        CancellationToken ct)
    {
        var requestContext = RequestContext.FromHttpContext(httpContext);
        var result = await authService.GoogleLoginAsync(request, requestContext, ct);

        if (result.SessionTicket is SessionTicket ticket)
        {
            var options = cookieService.CreateSessionCookie(ticket.ExpiresAt);
            httpContext.Response.Cookies.Append("sid", ticket.SessionId, options);
        }

        return result.ToHttpResult();
    }
}
