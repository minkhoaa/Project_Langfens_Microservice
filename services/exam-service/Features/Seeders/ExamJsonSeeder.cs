using System.Text.Json;
using ExamService.Domains.Entities;
using ExamService.Features.Validation;
using ExamService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ExamService.Features.Seeders;

public static class ExamJsonSeeder
{
    private static readonly JsonSerializerOptions JsonOpts = new(JsonSerializerDefaults.Web);

    /// <summary>
    /// Loads JSON envelope files from <paramref name="seedDir"/> and inserts them as
    /// <see cref="ExamQuestion"/> rows. Idempotent: skips if any rows already exist.
    /// </summary>
    public static async Task SeedExamJsonAsync(
        this IHost app,
        string seedDir = "deploy/seeds/exams",
        CancellationToken ct = default)
    {
        await using var scope = app.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        var validator = scope.ServiceProvider.GetRequiredService<EnvelopeValidator>();
        var logger = scope.ServiceProvider
            .GetRequiredService<ILoggerFactory>()
            .CreateLogger("ExamJsonSeeder");

        // Idempotency: if the table already has rows, do nothing.
        if (await db.Questions.AnyAsync(ct))
        {
            logger.LogInformation("exam_questions has rows; skipping seed.");
            return;
        }

        if (!Directory.Exists(seedDir))
        {
            logger.LogWarning("Seed directory '{SeedDir}' not found; skipping exam seed.", seedDir);
            return;
        }

        var files = Directory
            .EnumerateFiles(seedDir, "*.json", SearchOption.AllDirectories)
            .OrderBy(f => f, StringComparer.Ordinal)
            .ToList();
        if (files.Count == 0)
        {
            logger.LogWarning("Seed directory '{SeedDir}' has no .json files.", seedDir);
            return;
        }

        // Seeds are full envelopes without a real ExamSection backing, so create
        // a single placeholder Exam + Section to satisfy the SectionId FK. Production
        // seeds will be authored with real SectionIds (see spec §3.6).
        var examId = Guid.NewGuid();
        var sectionId = Guid.NewGuid();
        var now = DateTimeOffset.UtcNow;

        db.Exams.Add(new Exam
        {
            Id = examId,
            Slug = $"seed-exam-{examId:N}",
            Title = "Seed Exam (auto-generated)",
            Category = "READING",
            Level = "B1",
            Status = "draft",
            DurationMin = 60,
            CreatedAt = now,
            UpdatedAt = now,
        });
        db.Sections.Add(new ExamSection
        {
            Id = sectionId,
            ExamId = examId,
            Idx = 0,
            Title = "Seed Section",
            InstructionsMd = "Seeded from JSON envelopes.",
        });
        await db.SaveChangesAsync(ct);

        var seededCount = 0;
        var skippedCount = 0;
        var idx = 0;

        foreach (var file in files)
        {
            try
            {
                using var fs = File.OpenRead(file);
                JsonElement envelope;
                using (var doc = await JsonDocument.ParseAsync(fs, cancellationToken: ct))
                {
                    envelope = doc.RootElement.Clone();
                }

                var valid = validator.Validate(envelope);

                var skillProp = valid.Typed.PayloadType.GetProperty("Skill")
                    ?? throw new EnvelopeValidationException("payload.Skill property missing");
                var skill = skillProp.GetValue(valid.Typed.Payload)?.ToString()
                    ?? throw new EnvelopeValidationException("payload.Skill is null");

                if (!envelope.TryGetProperty("payload", out var payloadEl))
                    throw new EnvelopeValidationException("payload missing");
                if (!envelope.TryGetProperty("correctAnswer", out var correctAnswerEl))
                    throw new EnvelopeValidationException("correctAnswer missing");

                db.Questions.Add(new ExamQuestion
                {
                    Id = Guid.NewGuid(),
                    SectionId = sectionId,
                    Idx = idx++,
                    Skill = skill,
                    Payload = JsonDocument.Parse(payloadEl.GetRawText()),
                    CorrectAnswer = JsonDocument.Parse(correctAnswerEl.GetRawText()),
                    SchemaVersion = "1.0.0",
                    CreatedAt = now,
                    UpdatedAt = now,
                });
                seededCount++;
            }
            catch (Exception ex)
            {
                skippedCount++;
                logger.LogError(ex, "Failed to seed envelope from '{File}'.", file);
            }
        }

        if (seededCount > 0)
            await db.SaveChangesAsync(ct);

        logger.LogInformation(
            "Seeded {Seeded} exam envelopes ({Skipped} skipped) from '{SeedDir}'.",
            seededCount, skippedCount, seedDir);
    }
}
