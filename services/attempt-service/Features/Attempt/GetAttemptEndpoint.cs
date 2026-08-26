using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Attempt;

public static class GetAttemptEndpoint
{
    public static IEndpointRouteBuilder MapGetAttempt(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/attempts/{id:guid}", async (
            Guid id,
            AttemptDbContext db,
            HttpContext http,
            CancellationToken ct) =>
        {
            var userId = Guid.Parse(http.User.FindFirst("sub")?.Value ?? "");
            var a = await db.Attempts
                .Include(x => x.Answers)
                .FirstOrDefaultAsync(x => x.Id == id, ct);
            if (a is null) return Results.NotFound();
            // Authorization: only owner or admin.
            if (a.UserId != userId && !http.User.IsInRole("Admin"))
                return Results.Forbid();
            return Results.Ok(a);
        }).RequireAuthorization();
        return app;
    }
}