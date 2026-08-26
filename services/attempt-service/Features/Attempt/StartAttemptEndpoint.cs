using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Infrastructure.Persistence;

namespace attempt_service.Features.Attempt;

public static class StartAttemptEndpoint
{
    public static IEndpointRouteBuilder MapStartAttempt(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/attempts", async (
            StartAttemptRequest req,
            AttemptDbContext db,
            IExamGateway exam,
            HttpContext http,
            CancellationToken ct) =>
        {
            var userId = Guid.Parse(http.User.FindFirst("sub")?.Value
                ?? throw new UnauthorizedAccessException("missing sub claim"));

            // Fetch the exam snapshot via gRPC (stub for Task 18).
            var correctAnswers = await exam.GetCorrectAnswersAsync(req.ExamId, showAnswers: false, ct);

            // Build a minimal PaperJson (in production, ExamGateway.GetPaperJsonAsync returns full envelope).
            var paper = new PaperJson(
                Id: req.ExamId, Slug: "", Title: "", DescriptionMd: null,
                Category: "READING", Level: "B1", DurationMin: 60, ImageUrl: null,
                Skill: "READING",
                Sections: Array.Empty<PaperSection>());

            var attempt = new Domain.Entities.Attempt
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                ExamId = req.ExamId,
                Status = "in_progress",
                StartedAt = DateTime.UtcNow,
                DurationSec = 0,
                PaperJson = JsonDocument.Parse(JsonSerializer.Serialize(paper,
                    new JsonSerializerOptions(JsonSerializerDefaults.Web))),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };
            db.Attempts.Add(attempt);
            await db.SaveChangesAsync(ct);
            return Results.Created($"/api/attempts/{attempt.Id}", new { id = attempt.Id });
        }).RequireAuthorization();
        return app;
    }
}

public sealed record StartAttemptRequest(Guid ExamId);