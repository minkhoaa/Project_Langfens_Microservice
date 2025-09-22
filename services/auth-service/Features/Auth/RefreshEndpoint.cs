using auth_service.Application.Auth;
using auth_service.Application.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace auth_service.Features.Auth;

public static class RefreshEndpoint
{
    public static RouteHandlerBuilder MapRefreshEndpoint(this RouteGroupBuilder group)
    {
        return group.MapPost("/refresh", RefreshAsync)
                    .Produces(StatusCodes.Status200OK)
                    .Produces(StatusCodes.Status401Unauthorized);
    }

    private static async Task<IResult> RefreshAsync(HttpContext httpContext,
                                                    [FromServices] IAuthService authService,
                                                    CancellationToken ct)
    {
        var requestContext = RequestContext.FromHttpContext(httpContext);
        var result = await authService.RefreshAsync(requestContext, ct);
        return result.ToHttpResult();
    }
}
