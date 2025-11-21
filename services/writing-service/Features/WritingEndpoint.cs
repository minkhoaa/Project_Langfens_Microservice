using Shared.Security.Roles;
using writing_service.Features.Handler;

namespace writing_service.Features;

public static class WritingEndpoint
{
    public static void MapWritingEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/writing");
        app.MapPost("/grade", WritingHandler.SubmitHandler).RequireAuthorization(Roles.User);
        
    }
    public static void MapWritingAdminEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/admin/speaking");
        app.MapPost("/create", WritingHandler.CreateExamHandler);

    }
}