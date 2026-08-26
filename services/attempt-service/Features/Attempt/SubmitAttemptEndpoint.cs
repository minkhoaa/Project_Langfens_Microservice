namespace attempt_service.Features.Attempt;

public static class SubmitAttemptEndpoint
{
    public static IEndpointRouteBuilder MapSubmitAttempt(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/attempts/{id:guid}/submit", async (
            Guid id,
            AttemptFlow flow,
            HttpContext http,
            CancellationToken ct) =>
        {
            // Delegate to AttemptFlow.SubmitAsync (Task 18).
            return Results.Ok(await flow.SubmitAsync(id, ct));
        }).RequireAuthorization();
        return app;
    }
}