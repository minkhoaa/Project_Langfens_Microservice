using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Attempt;

public static class GetResultEndpoint
{
    public static IEndpointRouteBuilder MapGetResult(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/attempts/{id:guid}/result", async (
            Guid id,
            AttemptDbContext db,
            HttpContext http,
            CancellationToken ct) =>
        {
            var userId = Guid.Parse(http.User.FindFirst("sub")?.Value ?? "");
            var a = await db.Attempts.AsNoTracking()
                .Include(x => x.Answers)
                .FirstOrDefaultAsync(x => x.Id == id, ct);
            if (a is null) return Results.NotFound();
            if (a.UserId != userId && !http.User.IsInRole("Admin"))
                return Results.Forbid();
            if (a.Status is not ("submitted" or "graded"))
                return Results.Conflict(new { message = "Attempt not yet graded", status = a.Status });
            return Results.Ok(new
            {
                id = a.Id,
                status = a.Status,
                rawScore = a.RawScore,
                scaledScore = a.ScaledScore,
                answers = a.Answers.Select(x => new
                {
                    questionId = x.QuestionId,
                    sectionId = x.SectionId,
                    awardedPoints = x.AwardedPoints,
                    isCorrect = x.IsCorrect,
                    ragFeedback = x.RagFeedbackJson?.RootElement.Clone(),
                }),
            });
        }).RequireAuthorization();
        return app;
    }
}