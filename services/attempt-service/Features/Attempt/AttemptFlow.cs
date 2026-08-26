using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.PublicContracts.Events;

namespace attempt_service.Features.Attempt;

/// <summary>
/// 3-step submit pipeline (spec §4.6):
///   1. Load    — fetch attempt + persisted answers + correct-answer envelopes.
///   2. Grade   — resolve grader per question, write AwardedPoints/IsCorrect.
///   3. Persist — single transaction wraps status change + score compute.
/// Then fires the MassTransit event and a 3s-timeout RAG explainer.
/// </summary>
public sealed class AttemptFlow(
    AttemptDbContext db,
    IExamGateway examGateway,
    GraderRegistry graders,
    AnswerEnvelopeReader reader,
    IGradeCalculator calc,
    RagExplainer rag,
    IPublishEndpoint bus,
    ILogger<AttemptFlow> log)
{
    public async Task<SubmitResult> SubmitAsync(Guid attemptId, CancellationToken ct)
    {
        // ── Step 1 — Load ────────────────────────────────────────────────────
        var attempt = await db.Attempts
            .Include(a => a.Answers)
            .FirstAsync(a => a.Id == attemptId, ct);

        PaperJson paper;
        try
        {
            paper = JsonSerializer.Deserialize<PaperJson>(
                attempt.PaperJson.RootElement.GetRawText(),
                new JsonSerializerOptions(JsonSerializerDefaults.Web))!;
        }
        catch (JsonException ex)
        {
            throw new InvalidOperationException("PaperJson malformed; cannot grade attempt", ex);
        }

        var correctAnswers = await examGateway.GetCorrectAnswersAsync(
            attempt.ExamId, showAnswers: true, ct);

        // ── Step 2 — Grade ───────────────────────────────────────────────────
        var rows = new List<AttemptAnswer>();
        var allQuestions = EnumerateQuestions(paper);

        foreach (var q in allQuestions)
        {
            var existing = attempt.Answers.FirstOrDefault(a => a.QuestionId == q.Id);
            string learnerJson = existing?.AnswerJson.RootElement.GetRawText() ?? "{}";

            AnswerEnvelope learnerEnv;
            AnswerEnvelope correctEnv;
            try
            {
                learnerEnv = reader.Read(learnerJson, q.Type);
                correctEnv = reader.Read(
                    correctAnswers.TryGetValue(q.Id, out var ca) ? ca : "{}",
                    q.Type);
            }
            catch (UnknownQuestionTypeException)
            {
                log.LogWarning(
                    "Skipping question {QuestionId} — unknown slug {Slug}",
                    q.Id, q.Type);
                continue;
            }

            if (!graders.TryResolve(q.Type, out var graderNullable))
            {
                log.LogWarning(
                    "No grader registered for {Slug}; marking {QuestionId} unanswered",
                    q.Type, q.Id);
                if (existing is not null)
                {
                    existing.AwardedPoints = 0m;
                    existing.IsCorrect = false;
                    rows.Add(existing);
                }
                continue;
            }

            var grader = graderNullable!;
            var result = grader.Grade(learnerEnv, correctEnv, NormalizationConfig.Default);

            if (existing is null)
            {
                existing = new AttemptAnswer
                {
                    AttemptId = attempt.Id,
                    SectionId = q.SectionId,
                    QuestionId = q.Id,
                    AnswerJson = JsonDocument.Parse(learnerJson),
                    AwardedPoints = result.AwardedPoints,
                    IsCorrect = result.IsCorrect,
                    AnsweredAt = DateTime.UtcNow,
                };
                db.AttemptAnswers.Add(existing);
            }
            else
            {
                existing.AwardedPoints = result.AwardedPoints;
                existing.IsCorrect = result.IsCorrect;
            }
            rows.Add(existing);
        }

        // ── Step 3 — Persist (single transaction) ───────────────────────────
        await using var tx = await db.Database.BeginTransactionAsync(ct);
        try
        {
            attempt.Status = "submitted";
            attempt.SubmittedAt = DateTime.UtcNow;
            attempt.GradedAt = attempt.Answers.All(a => a.IsCorrect != null)
                ? DateTime.UtcNow
                : null;

            await db.SaveChangesAsync(ct);
            await calc.ComputeAsync(attempt, rows, ct);
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }

        // Fire-and-forget RAG explainer (3s timeout). Swallow exceptions so the
        // host never crashes on a slow / failing ai-service.
        _ = SafeRagAsync(attempt.Id, attempt.ExamId);

        // Publish AttemptCompletedEvent (MassTransit; unchanged contract).
        // Signature: (UserId, AttemptId, Skill, Score).
        var score = (int)Math.Round(attempt.RawScore ?? 0m);
        await bus.Publish(
            new AttemptCompletedEvent(attempt.UserId, attempt.Id, "READING", score),
            ct);

        return new SubmitResult(attempt.Id, rows.Count);
    }

    private async Task SafeRagAsync(Guid attemptId, Guid examId)
    {
        try
        {
            await rag.ExplainAsync(attemptId, examId).WaitAsync(TimeSpan.FromSeconds(3));
        }
        catch (Exception ex)
        {
            log.LogWarning(ex, "RAG explainer failed or timed out for attempt {AttemptId}", attemptId);
        }
    }

    private static IEnumerable<PaperQuestion> EnumerateQuestions(PaperJson paper)
    {
        foreach (var section in paper.Sections)
        {
            foreach (var group in section.QuestionGroups)
            {
                foreach (var q in group.Questions)
                    yield return q;
            }

            // Backward-compat: legacy papers without questionGroups still carry
            // questions directly on the section.
            foreach (var q in section.Questions)
                yield return q;
        }
    }
}

public sealed record SubmitResult(Guid AttemptId, int GradedCount);
