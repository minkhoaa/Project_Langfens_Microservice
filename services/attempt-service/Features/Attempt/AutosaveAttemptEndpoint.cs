using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Features.Attempt;

public static class AutosaveAttemptEndpoint
{
    public static IEndpointRouteBuilder MapAutosaveAttempt(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/attempts/{id:guid}/autosave", async (
            Guid id,
            AutosaveRequest req,
            AttemptDbContext db,
            HttpContext http,
            CancellationToken ct) =>
        {
            var userId = Guid.Parse(http.User.FindFirst("sub")?.Value ?? "");
            var attempt = await db.Attempts.Include(a => a.Answers).FirstOrDefaultAsync(a => a.Id == id, ct);
            if (attempt is null) return Results.NotFound();
            if (attempt.UserId != userId) return Results.Forbid();

            var saved = 0;
            foreach (var incoming in req.Answers ?? [])
            {
                var existing = attempt.Answers.FirstOrDefault(a => a.QuestionId == incoming.QuestionId);
                if (existing is null)
                {
                    existing = new AttemptAnswer
                    {
                        AttemptId = attempt.Id,
                        QuestionId = incoming.QuestionId,
                        SectionId = incoming.SectionId,
                        AnswerJson = JsonDocument.Parse(incoming.AnswerJson),
                        AnsweredAt = DateTime.UtcNow,
                    };
                    db.AttemptAnswers.Add(existing);
                }
                else
                {
                    existing.AnswerJson = JsonDocument.Parse(incoming.AnswerJson);
                    existing.SectionId = incoming.SectionId;
                    existing.AwardedPoints = null;
                    existing.IsCorrect = null;
                }
                saved++;
            }
            attempt.Status = "in_progress";
            attempt.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
            return Results.Ok(new { saved });
        }).RequireAuthorization();
        return app;
    }
}

public sealed record AutosaveRequest(List<AutosaveItem>? Answers);
public sealed record AutosaveItem(Guid QuestionId, Guid SectionId, string AnswerJson);