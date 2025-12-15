using auth_service.Application.Auth;
using Microsoft.AspNetCore.Mvc;
using Shared.Security.Scopes;

namespace auth_service.Features.Auth;

public static class GetAllUsersEndpoint
{
    public static RouteHandlerBuilder MapGetAllUsersEndpoint(this RouteGroupBuilder group)
    {
        return group.MapGet("/users", GetAllUsersAsync)
            .Produces(StatusCodes.Status200OK);
    }

    private static Task<IResult> GetAllUsersAsync([FromServices] IAuthService authService, CancellationToken ct)
        => authService.GetAllUsersAsync(ct);
}
