using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Attempt;

public static class ListAttemptsEndpoint
{
    public static IEndpointRouteBuilder MapListAttempts(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/attempts", async (
            AttemptDbContext db,
            HttpContext http,
            int? page = null,
            int? pageSize = null,
            CancellationToken ct = default) =>
        {
            var userId = Guid.Parse(http.User.FindFirst("sub")?.Value ?? "");
            var p = page is null or <= 0 ? 1 : page.Value;
            var ps = pageSize is null or <= 0 ? 20 : Math.Min(pageSize.Value, 100);
            var query = db.Attempts.AsNoTracking().Where(a => a.UserId == userId);
            var rows = await query.OrderByDescending(a => a.CreatedAt)
                .Skip((p - 1) * ps).Take(ps)
                .Select(a => new
                {
                    a.Id,
                    a.ExamId,
                    a.Status,
                    a.StartedAt,
                    a.SubmittedAt,
                    a.RawScore,
                    a.ScaledScore,
                })
                .ToListAsync(ct);
            return Results.Ok(rows);
        }).RequireAuthorization();
        return app;
    }
}