using System.Text.Json;
using ExamService.Domains.Entities;
using ExamService.Features.Validation;
using ExamService.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ExamService.Features.Exams.AdminEndpoint;

public static class AdminQuestionUpsertEndpoint
{
    public static IEndpointRouteBuilder MapAdminQuestionUpsert(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/admin/questions", async (
            [FromBody] AdminUpsertRequest req,
            EnvelopeValidator validator,
            ExamDbContext db,
            CancellationToken ct) =>
        {
            // 1. Validate envelope (slug → typed payload, discriminator check, DataAnnotations).
            // Throws EnvelopeValidationException on bad input — translated to 400 by the global handler.
            var valid = validator.Validate(req.Envelope);

            // 2. Extract Skill from typed payload via reflection.
            // payload.skill is a per-slug enum (MultipleChoiceSinglePayloadSkill etc.) whose
            // .ToString() yields the SSOT slug ("READING" | "LISTENING") — see QuestionSchema.cs.
            var skillProp = valid.Typed.PayloadType.GetProperty("Skill")
                ?? throw new EnvelopeValidationException("payload.Skill property missing");
            var skill = skillProp.GetValue(valid.Typed.Payload)?.ToString()
                ?? throw new EnvelopeValidationException("payload.Skill is null");

            // 3. Re-parse payload + correctAnswer into JsonDocument for jsonb storage
            //    (verbatim from wire — preserves key ordering, formatting, comments if any).
            var payloadEl = req.Envelope.GetProperty("payload");
            if (!req.Envelope.TryGetProperty("correctAnswer", out var correctAnswerEl))
                throw new EnvelopeValidationException("correctAnswer missing");

            var row = new ExamQuestion
            {
                Id = Guid.NewGuid(),
                SectionId = req.SectionId,
                GroupId = req.GroupId,
                Idx = req.Idx,
                Skill = skill,
                Payload = JsonDocument.Parse(payloadEl.GetRawText()),
                CorrectAnswer = JsonDocument.Parse(correctAnswerEl.GetRawText()),
                SchemaVersion = "1.0.0",
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };
            db.Questions.Add(row);
            await db.SaveChangesAsync(ct);
            return Results.Created($"/api/admin/questions/{row.Id}", new { id = row.Id });
        })
        .RequireAuthorization("AdminPolicy");
        return app;
    }
}

public sealed record AdminUpsertRequest(
    Guid SectionId,
    Guid? GroupId,
    int Idx,
    JsonElement Envelope);
