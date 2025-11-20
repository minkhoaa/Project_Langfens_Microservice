using Shared.Security.Roles;
using writing_service.Features.Handler;

namespace writing_service.Features;

public static class WritingEndpoint
{
    public static void MapWritingEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/writing");
        app.MapPost("/grade", WritingHandler.Grade).RequireAuthorization(Roles.User);
    }
}