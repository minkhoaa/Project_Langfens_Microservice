using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Features.ReadingPaper;

/// <summary>
/// Phase 14: Feedback capture service.
/// Computes exact diffs, SHA-256 hashes, taxonomy reasons, downstream impact,
/// and atomically writes ReadingPaperHumanFeedback + HUMAN_FEEDBACK_CAPTURED outbox event
/// within the calling transaction.
/// </summary>
public static class FeedbackService
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

    public static async Task<ReadingPaperHumanFeedback?> RecordExamEditAsync(
        ExamDbContext db,
        Exam before,
        Exam after,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.ExamId == before.Id && l.EntityType == "EXAM", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            title = before.Title,
            descriptionMd = before.DescriptionMd,
            category = before.Category,
            level = before.Level,
            durationMin = before.DurationMin,
            status = before.Status,
            imageUrl = before.ImageUrl
        };

        var afterPayload = new
        {
            title = after.Title,
            descriptionMd = after.DescriptionMd,
            category = after.Category,
            level = after.Level,
            durationMin = after.DurationMin,
            status = after.Status,
            imageUrl = after.ImageUrl
        };

        var diff = ComputeDiff(beforePayload, afterPayload);
        var downstream = new[] { "ExamMetadataChanged" };

        return await CaptureFeedbackAsync(
            db, lineage, "EXAM", before.Id.ToString(),
            beforePayload, afterPayload, diff,
            FeedbackActions.Update, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordExamDeleteAsync(
        ExamDbContext db,
        Exam before,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.ExamId == before.Id && l.EntityType == "EXAM", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            title = before.Title,
            descriptionMd = before.DescriptionMd,
            category = before.Category,
            level = before.Level,
            durationMin = before.DurationMin,
            status = before.Status
        };

        var downstream = new[] { "ExamDeleted", "RunOrphaned", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "EXAM", before.Id.ToString(),
            beforePayload, null, new { action = "DELETED" },
            FeedbackActions.Delete, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordSectionAddAsync(
        ExamDbContext db,
        ExamSection section,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.ExamId == section.ExamId && l.EntityType == "EXAM", ct);

        if (lineage == null) return null;

        var afterPayload = new
        {
            id = section.Id,
            examId = section.ExamId,
            idx = section.Idx,
            title = section.Title,
            instructionsMd = section.InstructionsMd,
            passageMd = section.PassageMd,
            audioUrl = section.AudioUrl,
            transcriptMd = section.TranscriptMd
        };

        var downstream = new[] { "SectionAdded", "StructuralChange", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "SECTION", section.Id.ToString(),
            null, afterPayload, new { added = afterPayload },
            FeedbackActions.Create, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordSectionEditAsync(
        ExamDbContext db,
        ExamSection before,
        ExamSection after,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.SectionId == before.Id && l.EntityType == "SECTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            title = before.Title,
            instructionsMd = before.InstructionsMd,
            passageMd = before.PassageMd,
            audioUrl = before.AudioUrl,
            transcriptMd = before.TranscriptMd
        };

        var afterPayload = new
        {
            idx = after.Idx,
            title = after.Title,
            instructionsMd = after.InstructionsMd,
            passageMd = after.PassageMd,
            audioUrl = after.AudioUrl,
            transcriptMd = after.TranscriptMd
        };

        var diff = ComputeDiff(beforePayload, afterPayload);
        var downstream = new[] { "PassageChanged", "AffectsAllSectionQuestions", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "SECTION", before.Id.ToString(),
            beforePayload, afterPayload, diff,
            FeedbackActions.Update, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordSectionDeleteAsync(
        ExamDbContext db,
        ExamSection before,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.SectionId == before.Id && l.EntityType == "SECTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            title = before.Title,
            instructionsMd = before.InstructionsMd,
            passageMd = before.PassageMd
        };

        var downstream = new[] { "SectionDeleted", "StructuralChange", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "SECTION", before.Id.ToString(),
            beforePayload, null, new { action = "DELETED" },
            FeedbackActions.Delete, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordQuestionAddAsync(
        ExamDbContext db,
        ExamQuestion question,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.SectionId == question.SectionId && l.EntityType == "SECTION", ct);

        if (lineage == null)
        {
            var sec = await db.ExamSections.AsNoTracking().FirstOrDefaultAsync(s => s.Id == question.SectionId, ct);
            if (sec != null)
            {
                lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
                    .FirstOrDefaultAsync(l => l.ExamId == sec.ExamId && l.EntityType == "EXAM", ct);
            }
        }

        if (lineage == null) return null;

        var afterPayload = new
        {
            id = question.Id,
            sectionId = question.SectionId,
            idx = question.Idx,
            type = question.Type,
            skill = question.Skill,
            difficulty = question.Difficulty,
            promptMd = question.PromptMd,
            explanationMd = question.ExplanationMd,
            imageUrl = question.ImageUrl,
            blankAcceptTexts = question.BlankAcceptTexts,
            blankAcceptRegex = question.BlankAcceptRegex,
            matchPairs = question.MatchPairs,
            orderCorrects = question.OrderCorrects,
            shortAnswerAcceptTexts = question.ShortAnswerAcceptTexts,
            shortAnswerAcceptRegex = question.ShortAnswerAcceptRegex
        };

        var downstream = new[] { "QuestionAdded", "StructuralChange", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "QUESTION", question.Id.ToString(),
            null, afterPayload, new { added = afterPayload },
            FeedbackActions.Create, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordQuestionEditAsync(
        ExamDbContext db,
        ExamQuestion before,
        ExamQuestion after,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.QuestionId == before.Id && l.EntityType == "QUESTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            type = before.Type,
            skill = before.Skill,
            difficulty = before.Difficulty,
            promptMd = before.PromptMd,
            explanationMd = before.ExplanationMd,
            imageUrl = before.ImageUrl,
            blankAcceptTexts = before.BlankAcceptTexts,
            blankAcceptRegex = before.BlankAcceptRegex,
            matchPairs = before.MatchPairs,
            orderCorrects = before.OrderCorrects,
            shortAnswerAcceptTexts = before.ShortAnswerAcceptTexts,
            shortAnswerAcceptRegex = before.ShortAnswerAcceptRegex
        };

        var afterPayload = new
        {
            idx = after.Idx,
            type = after.Type,
            skill = after.Skill,
            difficulty = after.Difficulty,
            promptMd = after.PromptMd,
            explanationMd = after.ExplanationMd,
            imageUrl = after.ImageUrl,
            blankAcceptTexts = after.BlankAcceptTexts,
            blankAcceptRegex = after.BlankAcceptRegex,
            matchPairs = after.MatchPairs,
            orderCorrects = after.OrderCorrects,
            shortAnswerAcceptTexts = after.ShortAnswerAcceptTexts,
            shortAnswerAcceptRegex = after.ShortAnswerAcceptRegex
        };

        var diff = ComputeDiff(beforePayload, afterPayload);
        var downstream = new[] { "QuestionChanged", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "QUESTION", before.Id.ToString(),
            beforePayload, afterPayload, diff,
            FeedbackActions.Update, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordQuestionDeleteAsync(
        ExamDbContext db,
        ExamQuestion before,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.QuestionId == before.Id && l.EntityType == "QUESTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            type = before.Type,
            skill = before.Skill,
            difficulty = before.Difficulty,
            promptMd = before.PromptMd,
            explanationMd = before.ExplanationMd
        };

        var downstream = new[] { "QuestionDeleted", "StructuralChange", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "QUESTION", before.Id.ToString(),
            beforePayload, null, new { action = "DELETED" },
            FeedbackActions.Delete, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordOptionAddAsync(
        ExamDbContext db,
        ExamOption option,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.QuestionId == option.QuestionId && l.EntityType == "QUESTION", ct);

        if (lineage == null)
        {
            var q = await db.ExamQuestions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == option.QuestionId, ct);
            if (q != null)
            {
                var sec = await db.ExamSections.AsNoTracking().FirstOrDefaultAsync(s => s.Id == q.SectionId, ct);
                if (sec != null)
                {
                    lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
                        .FirstOrDefaultAsync(l => l.ExamId == sec.ExamId && l.EntityType == "EXAM", ct);
                }
            }
        }

        if (lineage == null) return null;

        var afterPayload = new
        {
            id = option.Id,
            questionId = option.QuestionId,
            idx = option.Idx,
            contentMd = option.ContentMd,
            isCorrect = option.IsCorrect,
            imageUrl = option.ImageUrl,
            altText = option.AltText
        };

        var downstream = new[] { "OptionAdded", "OptionSetChanged", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "OPTION", option.Id.ToString(),
            null, afterPayload, new { added = afterPayload },
            FeedbackActions.Create, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordOptionEditAsync(
        ExamDbContext db,
        ExamOption before,
        ExamOption after,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.OptionId == before.Id && l.EntityType == "OPTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            contentMd = before.ContentMd,
            isCorrect = before.IsCorrect,
            imageUrl = before.ImageUrl,
            altText = before.AltText
        };

        var afterPayload = new
        {
            idx = after.Idx,
            contentMd = after.ContentMd,
            isCorrect = after.IsCorrect,
            imageUrl = after.ImageUrl,
            altText = after.AltText
        };

        var diff = ComputeDiff(beforePayload, afterPayload);
        var downstream = new[] { "OptionChanged", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "OPTION", before.Id.ToString(),
            beforePayload, afterPayload, diff,
            FeedbackActions.Update, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    public static async Task<ReadingPaperHumanFeedback?> RecordOptionDeleteAsync(
        ExamDbContext db,
        ExamOption before,
        string? editorId = null,
        string? editorRole = null,
        string[]? reasons = null,
        string? comment = null,
        string? idempotencyKey = null,
        CancellationToken ct = default)
    {
        var lineage = await db.ReadingPaperEntityLineages.AsNoTracking()
            .FirstOrDefaultAsync(l => l.OptionId == before.Id && l.EntityType == "OPTION", ct);

        if (lineage == null) return null;

        var beforePayload = new
        {
            idx = before.Idx,
            contentMd = before.ContentMd,
            isCorrect = before.IsCorrect
        };

        var downstream = new[] { "OptionDeleted", "OptionSetChanged", "RequiresRecheck", "InvalidatesRunEvaluation" };

        return await CaptureFeedbackAsync(
            db, lineage, "OPTION", before.Id.ToString(),
            beforePayload, null, new { action = "DELETED" },
            FeedbackActions.Delete, editorId, editorRole, reasons, comment,
            downstream, idempotencyKey, ct);
    }

    private static async Task<ReadingPaperHumanFeedback> CaptureFeedbackAsync(
        ExamDbContext db,
        ReadingPaperEntityLineage lineage,
        string targetEntityType,
        string targetEntityId,
        object? beforePayloadObj,
        object? afterPayloadObj,
        object diffObj,
        string actionType,
        string? editorId,
        string? editorRole,
        string[]? reasons,
        string? comment,
        string[] downstreamImpact,
        string? idempotencyKey,
        CancellationToken ct)
    {
        var beforePayloadJson = beforePayloadObj != null ? JsonSerializer.Serialize(beforePayloadObj, JsonOpts) : "null";
        var afterPayloadJson = afterPayloadObj != null ? JsonSerializer.Serialize(afterPayloadObj, JsonOpts) : "null";
        var diffJson = JsonSerializer.Serialize(diffObj, JsonOpts);

        var beforeHash = LineageService.ComputeSha256(beforePayloadJson);
        var afterHash = LineageService.ComputeSha256(afterPayloadJson);

        var resolvedEditorId = !string.IsNullOrWhiteSpace(editorId) ? editorId : "admin";
        var resolvedEditorRole = !string.IsNullOrWhiteSpace(editorRole) ? editorRole : "ADMIN";

        var effectiveIdempotencyKey = !string.IsNullOrWhiteSpace(idempotencyKey)
            ? idempotencyKey.Trim()
            : LineageService.ComputeSha256($"{targetEntityId}:{beforeHash}:{afterHash}:{resolvedEditorId}");

        // Idempotency check: if already processed, return existing
        var existing = await db.ReadingPaperHumanFeedbacks
            .FirstOrDefaultAsync(f => f.IdempotencyKey == effectiveIdempotencyKey, ct);

        if (existing != null)
        {
            return existing;
        }

        var feedbackId = $"fb-{Guid.NewGuid():N}";
        var now = DateTime.UtcNow;
        var feedback = new ReadingPaperHumanFeedback
        {
            FeedbackId = feedbackId,
            RunId = lineage.RunId,
            ExamId = lineage.ExamId,
            SectionId = lineage.SectionId,
            QuestionId = lineage.QuestionId,
            OptionId = lineage.OptionId,
            TargetEntityType = targetEntityType,
            TargetEntityId = targetEntityId,
            ArtifactId = lineage.ArtifactId,
            ArtifactVersion = lineage.ArtifactVersion,
            BeforeContentHash = beforeHash,
            AfterContentHash = afterHash,
            BeforePayloadJson = beforePayloadJson,
            AfterPayloadJson = afterPayloadJson,
            DiffJson = diffJson,
            EditorId = !string.IsNullOrWhiteSpace(editorId) ? editorId : "admin",
            EditorRole = !string.IsNullOrWhiteSpace(editorRole) ? editorRole : "ADMIN",
            ReasonsJson = JsonSerializer.Serialize(reasons ?? Array.Empty<string>(), JsonOpts),
            Comment = comment ?? string.Empty,
            DownstreamImpactJson = JsonSerializer.Serialize(downstreamImpact, JsonOpts),
            ActionType = actionType,
            CurationStatus = CurationStatuses.Raw,
            IdempotencyKey = effectiveIdempotencyKey,
            CreatedAt = now
        };

        db.ReadingPaperHumanFeedbacks.Add(feedback);

        // Sequence calculation for per-run uniqueness
        var maxSeq = await db.ReadingPaperEventOutbox
            .Where(e => e.RunId == lineage.RunId)
            .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;

        var outboxPayload = new
        {
            feedbackId = feedback.FeedbackId,
            runId = feedback.RunId,
            examId = feedback.ExamId,
            sectionId = feedback.SectionId,
            questionId = feedback.QuestionId,
            optionId = feedback.OptionId,
            targetEntityType = feedback.TargetEntityType,
            targetEntityId = feedback.TargetEntityId,
            artifactId = feedback.ArtifactId,
            artifactVersion = feedback.ArtifactVersion,
            beforeContentHash = feedback.BeforeContentHash,
            afterContentHash = feedback.AfterContentHash,
            beforePayloadJson = feedback.BeforePayloadJson,
            afterPayloadJson = feedback.AfterPayloadJson,
            diffJson = feedback.DiffJson,
            reasons = reasons ?? Array.Empty<string>(),
            comment = feedback.Comment,
            downstreamImpact = downstreamImpact,
            actionType = feedback.ActionType,
            editorId = feedback.EditorId,
            editorRole = feedback.EditorRole,
            timestamp = feedback.CreatedAt
        };

        var outboxEvent = new ReadingPaperEventOutbox
        {
            RunId = lineage.RunId,
            EventId = $"fb-outbox-{feedback.FeedbackId}",
            Sequence = maxSeq + 1,
            EventType = "HUMAN_FEEDBACK_CAPTURED",
            IdempotencyKey = feedback.IdempotencyKey,
            Epoch = 1,
            PayloadJson = JsonSerializer.Serialize(outboxPayload, JsonOpts),
            Status = "PENDING",
            CreatedAt = now
        };

        db.ReadingPaperEventOutbox.Add(outboxEvent);

        return feedback;
    }

    private static Dictionary<string, object?> ComputeDiff(object before, object after)
    {
        var beforeDict = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(JsonSerializer.Serialize(before, JsonOpts), JsonOpts) ?? new();
        var afterDict = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(JsonSerializer.Serialize(after, JsonOpts), JsonOpts) ?? new();

        var diff = new Dictionary<string, object?>();
        var allKeys = beforeDict.Keys.Union(afterDict.Keys);

        foreach (var key in allKeys)
        {
            beforeDict.TryGetValue(key, out var beforeVal);
            afterDict.TryGetValue(key, out var afterVal);

            var beforeStr = beforeVal.ValueKind != JsonValueKind.Undefined ? beforeVal.GetRawText() : null;
            var afterStr = afterVal.ValueKind != JsonValueKind.Undefined ? afterVal.GetRawText() : null;

            if (beforeStr != afterStr)
            {
                diff[key] = new
                {
                    before = beforeVal.ValueKind != JsonValueKind.Undefined ? JsonSerializer.Deserialize<object>(beforeStr!) : null,
                    after = afterVal.ValueKind != JsonValueKind.Undefined ? JsonSerializer.Deserialize<object>(afterStr!) : null
                };
            }
        }

        return diff;
    }
}
