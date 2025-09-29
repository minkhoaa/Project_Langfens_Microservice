using attempt_service.Features.Attempt.AttemptEndpoint;

namespace attempt_service.Features.Attempt;

public static class AttemptEndpointMapping
{
    public static void MapAttemptEndpoint(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/attempt");
        app.MapPost("/attempts:start", AttemptHandler.AttemptStartHandler);
    }
}