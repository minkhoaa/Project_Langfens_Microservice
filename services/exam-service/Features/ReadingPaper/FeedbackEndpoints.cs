using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper.Contracts;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.Security.Roles;

namespace exam_service.Features.ReadingPaper;

public static class FeedbackEndpoints
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public static void MapFeedbackEndpoints(this IEndpointRouteBuilder app)
    {
        var feedbackGroup = app.MapGroup("/api/v2/reading/feedback")
            .WithTags("Reading Paper Feedback")
            .RequireAuthorization(Roles.Admin);

        feedbackGroup.MapGet("/", GetFeedbackList);
        feedbackGroup.MapGet("/{id}", GetFeedbackById);
        feedbackGroup.MapPost("/{id}/review", ReviewFeedback);

        var papersGroup = app.MapGroup("/api/v2/reading/papers")
            .WithTags("Reading Paper Curation")
            .RequireAuthorization(Roles.Admin);

        papersGroup.MapPost("/{examId:guid}/accept", AcceptPaper);
        papersGroup.MapPost("/{examId:guid}/reject", RejectPaper);
        papersGroup.MapPost("/{examId:guid}/publish", PublishPaper);
    }

    public sealed record RejectPaperPayload(
        IReadOnlyList<string>? Reasons = null,
        string? Comment = null,
        string? IdempotencyKey = null);

    public sealed record AcceptPaperPayload(
        IReadOnlyList<string>? Reasons = null,
        string? Comment = null,
        string? IdempotencyKey = null);

    public sealed record PublishPaperPayload(
        string? Comment = null,
        string? IdempotencyKey = null);

    private static string ComputeDeterministicKey(string action, Guid examId, string editorId)
    {
        var raw = $"{action.ToLowerInvariant()}:{examId}:{editorId.ToLowerInvariant()}";
        using var sha = SHA256.Create();
        var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(raw));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    private static async Task<IResult> GetFeedbackList(
        [FromQuery] Guid? examId,
        [FromQuery] string? runId,
        [FromQuery] string? curationStatus,
        [FromQuery] int page,
        [FromQuery] int maxSize,
        ExamDbContext db,
        CancellationToken ct)
    {
        var currentPage = page > 0 ? page : 1;
        var pageSize = maxSize is > 0 and <= 100 ? maxSize : 50;

        IQueryable<ReadingPaperHumanFeedback> query = db.ReadingPaperHumanFeedbacks.AsNoTracking();

        if (examId.HasValue && examId.Value != Guid.Empty)
        {
            query = query.Where(x => x.ExamId == examId.Value);
        }

        if (!string.IsNullOrWhiteSpace(runId))
        {
            query = query.Where(x => x.RunId == runId.Trim());
        }

        var feedbackList = await query
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync(ct);

        var feedbackIds = feedbackList.Select(x => x.FeedbackId).Distinct().ToList();

        // Load latest curation record per feedbackId (append-only audit trail)
        var latestCurationRecords = await db.ReadingPaperFeedbackCurationRecords.AsNoTracking()
            .Where(r => feedbackIds.Contains(r.FeedbackId))
            .OrderByDescending(r => r.ReviewedAt)
            .ToListAsync(ct);

        var latestCurationMap = latestCurationRecords
            .GroupBy(r => r.FeedbackId)
            .ToDictionary(g => g.Key, g => g.First());

        var dtos = new List<HumanFeedbackDto>();
        foreach (var item in feedbackList)
        {
            // Immutable curation status: defaults strictly to RAW if no curation record exists
            var effectiveStatus = latestCurationMap.TryGetValue(item.FeedbackId, out var cur)
                ? cur.ToStatus
                : CurationStatuses.Raw;

            if (!string.IsNullOrWhiteSpace(curationStatus))
            {
                var filterStatus = curationStatus.Trim().ToUpperInvariant();
                if (!string.Equals(effectiveStatus, filterStatus, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }
            }

            dtos.Add(MapToDto(item, effectiveStatus));
        }

        var totalCount = dtos.Count;
        var pagedItems = dtos
            .Skip((currentPage - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        return Results.Ok(new
        {
            total = totalCount,
            page = currentPage,
            maxSize = pageSize,
            items = pagedItems
        });
    }

    private static async Task<IResult> GetFeedbackById(
        string id,
        ExamDbContext db,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(id))
        {
            return Results.BadRequest(new { error = "Feedback ID is required" });
        }

        var isGuid = Guid.TryParse(id, out var guidId);

        var feedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
            .FirstOrDefaultAsync(x => (isGuid && x.Id == guidId) || x.FeedbackId == id, ct);

        if (feedback is null)
        {
            return Results.NotFound(new { error = $"Feedback '{id}' not found" });
        }

        var latestCuration = await db.ReadingPaperFeedbackCurationRecords.AsNoTracking()
            .Where(r => r.FeedbackId == feedback.FeedbackId)
            .OrderByDescending(r => r.ReviewedAt)
            .FirstOrDefaultAsync(ct);

        // Immutable curation status: defaults strictly to RAW if no curation record exists
        var effectiveStatus = latestCuration?.ToStatus ?? CurationStatuses.Raw;

        return Results.Ok(MapToDto(feedback, effectiveStatus));
    }

    private static async Task<IResult> ReviewFeedback(
        string id,
        [FromHeader(Name = "Idempotency-Key")] string? headerKey,
        [FromBody] FeedbackReviewRequest request,
        ExamDbContext db,
        ClaimsPrincipal user,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(id))
        {
            return Results.BadRequest(new { error = "Feedback ID is required" });
        }

        var normalizedStatus = request.CurationStatus?.Trim().ToUpperInvariant() ?? CurationStatuses.Reviewed;
        if (!CurationStatuses.IsKnown(normalizedStatus))
        {
            return Results.BadRequest(new
            {
                error = $"Invalid curation status '{request.CurationStatus}'. Allowed: {string.Join(", ", CurationStatuses.All)}"
            });
        }

        var isGuid = Guid.TryParse(id, out var guidId);

        // Fetch original feedback without mutating it
        var feedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
            .FirstOrDefaultAsync(x => (isGuid && x.Id == guidId) || x.FeedbackId == id, ct);

        if (feedback is null)
        {
            return Results.NotFound(new { error = $"Feedback '{id}' not found" });
        }
        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = db.Database.IsRelational() ? await db.Database.BeginTransactionAsync(ct) : null;

            if (db.Database.IsRelational())
            {
                // Explicit row lock on feedback record to serialize concurrent reviewers
                await db.Database.ExecuteSqlRawAsync(
                    "SELECT 1 FROM reading_paper_human_feedback WHERE \"FeedbackId\" = {0} FOR UPDATE",
                    new object[] { feedback.FeedbackId },
                    ct);
            }

            // Determine current status from latest curation record within the transaction
            var latestCuration = await db.ReadingPaperFeedbackCurationRecords
                .Where(r => r.FeedbackId == feedback.FeedbackId)
                .OrderByDescending(r => r.ReviewedAt)
                .FirstOrDefaultAsync(ct);
            var currentStatus = latestCuration?.ToStatus ?? CurationStatuses.Raw;

            // Concurrency / CAS guard: if expectedCurrentStatus provided, ensure it matches
            if (!string.IsNullOrWhiteSpace(request.ExpectedCurrentStatus))
            {
                var expected = request.ExpectedCurrentStatus.Trim().ToUpperInvariant();
                if (!string.Equals(currentStatus, expected, StringComparison.OrdinalIgnoreCase))
                {
                    if (tx != null) await tx.RollbackAsync(ct);
                    return Results.Conflict(new
                    {
                        error = $"Conflict: expected status was '{expected}', but current status is '{currentStatus}'."
                    });
                }
            }

            // State machine transition validation:
            // Allowed transitions:
            // RAW -> ANNOTATED or REJECTED
            // ANNOTATED -> REVIEWED or REJECTED
            // REVIEWED -> CURATED or REJECTED
            bool isValidTransition = (currentStatus, normalizedStatus) switch
            {
                (CurationStatuses.Raw, CurationStatuses.Annotated) => true,
                (CurationStatuses.Raw, CurationStatuses.Rejected) => true,
                (CurationStatuses.Annotated, CurationStatuses.Reviewed) => true,
                (CurationStatuses.Annotated, CurationStatuses.Rejected) => true,
                (CurationStatuses.Reviewed, CurationStatuses.Curated) => true,
                (CurationStatuses.Reviewed, CurationStatuses.Rejected) => true,
                _ => false
            };

            if (!isValidTransition)
            {
                if (tx != null) await tx.RollbackAsync(ct);
                return Results.BadRequest(new
                {
                    error = $"Invalid status transition from {currentStatus} to {normalizedStatus}. Must follow RAW -> ANNOTATED -> REVIEWED -> CURATED."
                });
            }

            // Strict Reviewer Identity: derive exclusively from verified claims (no body fallback to prevent spoofing)
            var reviewerId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                             ?? user.FindFirst("sub")?.Value
                             ?? user.FindFirst(ClaimTypes.Email)?.Value
                             ?? user.FindFirst("email")?.Value;

            if (string.IsNullOrWhiteSpace(reviewerId))
            {
                if (tx != null) await tx.RollbackAsync(ct);
                return Results.BadRequest(new { error = "Authenticated reviewer identity is required." });
            }

            var idempotencyKey = !string.IsNullOrWhiteSpace(headerKey)
                ? headerKey.Trim()
                : (!string.IsNullOrWhiteSpace(request.IdempotencyKey)
                    ? request.IdempotencyKey.Trim()
                    : ComputeDeterministicKey($"review:{normalizedStatus}", feedback.ExamId, reviewerId));

            // Idempotency check: if already reviewed with same idempotency key, return early
            var existingWithKey = await db.ReadingPaperFeedbackCurationRecords.AsNoTracking()
                .FirstOrDefaultAsync(r => r.FeedbackId == feedback.FeedbackId && r.IdempotencyKey == idempotencyKey, ct);
            if (existingWithKey is not null)
            {
                if (tx != null) await tx.RollbackAsync(ct);
                return Results.Ok(MapToDto(feedback, existingWithKey.ToStatus));
            }

            // Insert append-only curation audit record (feedback row is 100% immutable)
            var curationRecord = new ReadingPaperFeedbackCurationRecord
            {
                ReviewId = $"rev-{feedback.FeedbackId}-{DateTime.UtcNow.Ticks}",
                FeedbackId = feedback.FeedbackId,
                FromStatus = currentStatus,
                ToStatus = normalizedStatus,
                ReviewerId = reviewerId,
                ReviewerRole = "ADMIN",
                ReviewNotes = request.ReviewerNotes ?? string.Empty,
                Action = "REVIEW",
                IdempotencyKey = idempotencyKey,
                ReviewedAt = DateTime.UtcNow
            };

            db.ReadingPaperFeedbackCurationRecords.Add(curationRecord);
            await db.SaveChangesAsync(ct);
            if (tx != null) await tx.CommitAsync(ct);

            return Results.Ok(MapToDto(feedback, normalizedStatus));
        });
    }

    private static async Task<IResult> AcceptPaper(
        Guid examId,
        [FromHeader(Name = "Idempotency-Key")] string? headerKey,
        [FromBody] AcceptPaperPayload? payload,
        ExamDbContext db,
        ClaimsPrincipal user,
        CancellationToken ct)
    {
        var exam = await db.Exams.FirstOrDefaultAsync(x => x.Id == examId, ct);
        var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.ExamId == examId || x.Id == examId, ct);

        if (exam is null && job is null)
        {
            return Results.NotFound(new { error = $"Exam or ReadingPaperJob '{examId}' not found" });
        }

        var targetExamId = exam?.Id ?? job?.ExamId ?? examId;

        // Strict Actor Identity
        var editorId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? user.FindFirst("sub")?.Value
                       ?? user.FindFirst(ClaimTypes.Email)?.Value
                       ?? user.FindFirst("email")?.Value
                       ?? user.FindFirst(ClaimTypes.Name)?.Value
                       ?? user.FindFirst("name")?.Value;

        if (string.IsNullOrWhiteSpace(editorId))
        {
            return Results.BadRequest(new { error = "Actor identity is required." });
        }

        var reasons = payload?.Reasons ?? Array.Empty<string>();

        // Validate reasons taxonomy if provided
        foreach (var reason in reasons)
        {
            if (!FeedbackReasons.IsKnown(reason))
            {
                return Results.BadRequest(new
                {
                    error = $"Unknown reason '{reason}'. Canonical reasons: {string.Join(", ", FeedbackReasons.All)}"
                });
            }
        }

        var runId = job?.ActiveRunId ?? string.Empty;
        var idempotencyKey = !string.IsNullOrWhiteSpace(headerKey)
            ? headerKey.Trim()
            : (!string.IsNullOrWhiteSpace(payload?.IdempotencyKey)
                ? payload.IdempotencyKey.Trim()
                : ComputeDeterministicKey("accept", targetExamId, editorId));

        // Idempotency check: if feedback with key exists for this exam and action, return persisted record
        var existing = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
            .FirstOrDefaultAsync(f => f.TargetEntityId == targetExamId.ToString() && f.ActionType == FeedbackActions.Accept && f.IdempotencyKey == idempotencyKey, ct);
        if (existing is not null)
        {
            var persistedReasons = !string.IsNullOrWhiteSpace(existing.ReasonsJson)
                ? (JsonSerializer.Deserialize<List<string>>(existing.ReasonsJson, JsonOptions) ?? (IReadOnlyList<string>)reasons)
                : reasons;
            return Results.Ok(new
            {
                examId = targetExamId,
                status = "ACCEPTED",
                reasons = persistedReasons,
                comment = existing.Comment,
                feedbackId = existing.FeedbackId,
                message = "Reading paper accepted (idempotent replay)"
            });
        }

        var feedbackId = $"fb-accept-{targetExamId}-{DateTime.UtcNow.Ticks}";
        var now = DateTime.UtcNow;

        // Immutable human feedback evidence record (RAW action evidence, NOT curated ground truth)
        var feedback = new ReadingPaperHumanFeedback
        {
            FeedbackId = feedbackId,
            RunId = runId,
            ExamId = targetExamId,
            TargetEntityType = "EXAM",
            TargetEntityId = targetExamId.ToString(),
            ActionType = FeedbackActions.Accept,
            CurationStatus = CurationStatuses.Raw,
            ReasonsJson = JsonSerializer.Serialize(reasons, JsonOptions),
            Comment = payload?.Comment ?? string.Empty,
            EditorId = editorId,
            EditorRole = "ADMIN",
            IdempotencyKey = idempotencyKey,
            CreatedAt = now
        };

        db.ReadingPaperHumanFeedbacks.Add(feedback);

        // Atomic Outbox Event
        var maxSeq = await db.ReadingPaperEventOutbox
            .Where(e => e.RunId == runId)
            .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;

        var outboxPayload = new
        {
            feedbackId = feedback.FeedbackId,
            runId = feedback.RunId,
            examId = feedback.ExamId,
            targetEntityType = feedback.TargetEntityType,
            targetEntityId = feedback.TargetEntityId,
            actionType = feedback.ActionType,
            reasons,
            comment = feedback.Comment,
            editorId = feedback.EditorId,
            editorRole = feedback.EditorRole,
            timestamp = now
        };

        var outboxEvent = new ReadingPaperEventOutbox
        {
            RunId = runId,
            EventId = $"fb-outbox-{feedback.FeedbackId}",
            Sequence = maxSeq + 1,
            EventType = "HUMAN_FEEDBACK_CAPTURED",
            IdempotencyKey = feedback.IdempotencyKey,
            Epoch = 1,
            PayloadJson = JsonSerializer.Serialize(outboxPayload, JsonOptions),
            Status = "PENDING",
            CreatedAt = now
        };

        db.ReadingPaperEventOutbox.Add(outboxEvent);
        await db.SaveChangesAsync(ct);

        return Results.Ok(new
        {
            examId = targetExamId,
            status = "ACCEPTED",
            reasons,
            comment = payload?.Comment ?? string.Empty,
            feedbackId = feedback.FeedbackId,
            message = "Reading paper accepted by admin curator"
        });
    }

    private static async Task<IResult> RejectPaper(
        Guid examId,
        [FromHeader(Name = "Idempotency-Key")] string? headerKey,
        [FromBody] RejectPaperPayload? payload,
        ExamDbContext db,
        ClaimsPrincipal user,
        CancellationToken ct)
    {
        var exam = await db.Exams.FirstOrDefaultAsync(x => x.Id == examId, ct);
        var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.ExamId == examId || x.Id == examId, ct);

        if (exam is null && job is null)
        {
            return Results.NotFound(new { error = $"Exam or ReadingPaperJob '{examId}' not found" });
        }

        var targetExamId = exam?.Id ?? job?.ExamId ?? examId;

        // Strict Actor Identity
        var editorId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? user.FindFirst("sub")?.Value
                       ?? user.FindFirst(ClaimTypes.Email)?.Value
                       ?? user.FindFirst("email")?.Value
                       ?? user.FindFirst(ClaimTypes.Name)?.Value
                       ?? user.FindFirst("name")?.Value;

        if (string.IsNullOrWhiteSpace(editorId))
        {
            return Results.BadRequest(new { error = "Actor identity is required." });
        }

        var reasons = payload?.Reasons ?? Array.Empty<string>();

        // Validate reasons taxonomy if provided
        foreach (var reason in reasons)
        {
            if (!FeedbackReasons.IsKnown(reason))
            {
                return Results.BadRequest(new
                {
                    error = $"Unknown reason '{reason}'. Canonical reasons: {string.Join(", ", FeedbackReasons.All)}"
                });
            }
        }

        var runId = job?.ActiveRunId ?? string.Empty;
        var idempotencyKey = !string.IsNullOrWhiteSpace(headerKey)
            ? headerKey.Trim()
            : (!string.IsNullOrWhiteSpace(payload?.IdempotencyKey)
                ? payload.IdempotencyKey.Trim()
                : ComputeDeterministicKey("reject", targetExamId, editorId));

        // Idempotency check: if feedback with key exists for this exam and action, return persisted record
        var existing = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
            .FirstOrDefaultAsync(f => f.TargetEntityId == targetExamId.ToString() && f.ActionType == FeedbackActions.Reject && f.IdempotencyKey == idempotencyKey, ct);
        if (existing is not null)
        {
            var persistedReasons = !string.IsNullOrWhiteSpace(existing.ReasonsJson)
                ? (JsonSerializer.Deserialize<List<string>>(existing.ReasonsJson, JsonOptions) ?? (IReadOnlyList<string>)reasons)
                : reasons;
            return Results.Ok(new
            {
                examId = targetExamId,
                status = "REJECTED",
                reasons = persistedReasons,
                comment = existing.Comment,
                feedbackId = existing.FeedbackId,
                message = "Reading paper rejected (idempotent replay)"
            });
        }

        if (exam is not null)
        {
            exam.Status = ExamStatus.Archived;
            exam.UpdatedAt = DateTime.UtcNow;
        }

        if (job is not null)
        {
            job.Status = "Rejected";
            job.Error = payload?.Comment ?? string.Empty;
            job.UpdatedAt = DateTime.UtcNow;
        }

        var feedbackId = $"fb-reject-{targetExamId}-{DateTime.UtcNow.Ticks}";
        var now = DateTime.UtcNow;

        // Immutable human feedback evidence record (RAW action evidence)
        var feedback = new ReadingPaperHumanFeedback
        {
            FeedbackId = feedbackId,
            RunId = runId,
            ExamId = targetExamId,
            TargetEntityType = "EXAM",
            TargetEntityId = targetExamId.ToString(),
            ActionType = FeedbackActions.Reject,
            CurationStatus = CurationStatuses.Raw,
            ReasonsJson = JsonSerializer.Serialize(reasons, JsonOptions),
            Comment = payload?.Comment ?? string.Empty,
            EditorId = editorId,
            EditorRole = "ADMIN",
            IdempotencyKey = idempotencyKey,
            CreatedAt = now
        };

        db.ReadingPaperHumanFeedbacks.Add(feedback);

        // Atomic Outbox Event
        var maxSeq = await db.ReadingPaperEventOutbox
            .Where(e => e.RunId == runId)
            .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;

        var outboxPayload = new
        {
            feedbackId = feedback.FeedbackId,
            runId = feedback.RunId,
            examId = feedback.ExamId,
            targetEntityType = feedback.TargetEntityType,
            targetEntityId = feedback.TargetEntityId,
            actionType = feedback.ActionType,
            reasons,
            comment = feedback.Comment,
            editorId = feedback.EditorId,
            editorRole = feedback.EditorRole,
            timestamp = now
        };

        var outboxEvent = new ReadingPaperEventOutbox
        {
            RunId = runId,
            EventId = $"fb-outbox-{feedback.FeedbackId}",
            Sequence = maxSeq + 1,
            EventType = "HUMAN_FEEDBACK_CAPTURED",
            IdempotencyKey = feedback.IdempotencyKey,
            Epoch = 1,
            PayloadJson = JsonSerializer.Serialize(outboxPayload, JsonOptions),
            Status = "PENDING",
            CreatedAt = now
        };

        db.ReadingPaperEventOutbox.Add(outboxEvent);
        await db.SaveChangesAsync(ct);

        return Results.Ok(new
        {
            examId = targetExamId,
            status = "REJECTED",
            reasons,
            comment = payload?.Comment ?? string.Empty,
            feedbackId = feedback.FeedbackId,
            message = "Reading paper rejected with reason taxonomy"
        });
    }

    private static async Task<IResult> PublishPaper(
        Guid examId,
        [FromHeader(Name = "Idempotency-Key")] string? headerKey,
        [FromBody] PublishPaperPayload? payload,
        ExamDbContext db,
        ClaimsPrincipal user,
        CancellationToken ct)
    {
        var exam = await db.Exams.FirstOrDefaultAsync(x => x.Id == examId, ct);
        var job = await db.ReadingPaperJobs.FirstOrDefaultAsync(x => x.ExamId == examId || x.Id == examId, ct);

        if (exam is null && job?.ExamId is not null)
        {
            exam = await db.Exams.FirstOrDefaultAsync(x => x.Id == job.ExamId.Value, ct);
        }

        if (exam is null)
        {
            return Results.NotFound(new { error = $"Exam '{examId}' not found for publishing" });
        }

        // Strict Actor Identity
        var editorId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                       ?? user.FindFirst("sub")?.Value
                       ?? user.FindFirst(ClaimTypes.Email)?.Value
                       ?? user.FindFirst("email")?.Value
                       ?? user.FindFirst(ClaimTypes.Name)?.Value
                       ?? user.FindFirst("name")?.Value;

        if (string.IsNullOrWhiteSpace(editorId))
        {
            return Results.BadRequest(new { error = "Actor identity is required." });
        }

        var runId = job?.ActiveRunId ?? string.Empty;
        var idempotencyKey = !string.IsNullOrWhiteSpace(headerKey)
            ? headerKey.Trim()
            : (!string.IsNullOrWhiteSpace(payload?.IdempotencyKey)
                ? payload.IdempotencyKey.Trim()
                : ComputeDeterministicKey("publish", exam.Id, editorId));

        // Idempotency check: if feedback with key exists for this exam and action, return persisted record
        var existing = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
            .FirstOrDefaultAsync(f => f.TargetEntityId == exam.Id.ToString() && f.ActionType == FeedbackActions.Publish && f.IdempotencyKey == idempotencyKey, ct);
        if (existing is not null)
        {
            return Results.Ok(new
            {
                examId = exam.Id,
                slug = exam.Slug,
                title = exam.Title,
                status = exam.Status,
                message = "Reading paper published (idempotent replay)"
            });
        }

        exam.Status = ExamStatus.Published;
        exam.UpdatedAt = DateTime.UtcNow;

        if (job is not null)
        {
            job.Status = "Completed";
            job.UpdatedAt = DateTime.UtcNow;
        }

        var feedbackId = $"fb-publish-{exam.Id}-{DateTime.UtcNow.Ticks}";
        var now = DateTime.UtcNow;

        // Immutable human feedback evidence record (RAW action evidence)
        var feedback = new ReadingPaperHumanFeedback
        {
            FeedbackId = feedbackId,
            RunId = runId,
            ExamId = exam.Id,
            TargetEntityType = "EXAM",
            TargetEntityId = exam.Id.ToString(),
            ActionType = FeedbackActions.Publish,
            CurationStatus = CurationStatuses.Raw,
            ReasonsJson = "[]",
            Comment = payload?.Comment ?? string.Empty,
            EditorId = editorId,
            EditorRole = "ADMIN",
            IdempotencyKey = idempotencyKey,
            CreatedAt = now
        };

        db.ReadingPaperHumanFeedbacks.Add(feedback);

        // Atomic Outbox Event
        var maxSeq = await db.ReadingPaperEventOutbox
            .Where(e => e.RunId == runId)
            .MaxAsync(e => (long?)e.Sequence, ct) ?? 0L;

        var outboxPayload = new
        {
            feedbackId = feedback.FeedbackId,
            runId = feedback.RunId,
            examId = feedback.ExamId,
            targetEntityType = feedback.TargetEntityType,
            targetEntityId = feedback.TargetEntityId,
            actionType = feedback.ActionType,
            reasons = Array.Empty<string>(),
            comment = feedback.Comment,
            editorId = feedback.EditorId,
            editorRole = feedback.EditorRole,
            timestamp = now
        };

        var outboxEvent = new ReadingPaperEventOutbox
        {
            RunId = runId,
            EventId = $"fb-outbox-{feedback.FeedbackId}",
            Sequence = maxSeq + 1,
            EventType = "HUMAN_FEEDBACK_CAPTURED",
            IdempotencyKey = feedback.IdempotencyKey,
            Epoch = 1,
            PayloadJson = JsonSerializer.Serialize(outboxPayload, JsonOptions),
            Status = "PENDING",
            CreatedAt = now
        };

        db.ReadingPaperEventOutbox.Add(outboxEvent);
        await db.SaveChangesAsync(ct);

        return Results.Ok(new
        {
            examId = exam.Id,
            slug = exam.Slug,
            title = exam.Title,
            status = exam.Status,
            message = "Reading paper published successfully"
        });
    }

    private static HumanFeedbackDto MapToDto(ReadingPaperHumanFeedback entity, string? effectiveStatus = null)
    {
        IReadOnlyList<string> reasons;
        try
        {
            reasons = string.IsNullOrWhiteSpace(entity.ReasonsJson)
                ? Array.Empty<string>()
                : JsonSerializer.Deserialize<List<string>>(entity.ReasonsJson, JsonOptions) ?? (IReadOnlyList<string>)Array.Empty<string>();
        }
        catch
        {
            reasons = Array.Empty<string>();
        }

        return new HumanFeedbackDto(
            Id: entity.Id,
            FeedbackId: entity.FeedbackId,
            RunId: entity.RunId ?? string.Empty,
            ExamId: entity.ExamId,
            SectionId: entity.SectionId?.ToString(),
            QuestionId: entity.QuestionId?.ToString(),
            OptionId: entity.OptionId?.ToString(),
            TargetEntityType: entity.TargetEntityType,
            TargetEntityId: entity.TargetEntityId,
            ArtifactId: entity.ArtifactId,
            ArtifactVersion: entity.ArtifactVersion,
            BeforeContentHash: entity.BeforeContentHash,
            AfterContentHash: entity.AfterContentHash,
            BeforePayloadJson: entity.BeforePayloadJson,
            AfterPayloadJson: entity.AfterPayloadJson,
            DiffJson: entity.DiffJson,
            EditorId: entity.EditorId,
            EditorRole: entity.EditorRole,
            Reasons: reasons,
            Comment: entity.Comment,
            DownstreamImpactJson: entity.DownstreamImpactJson,
            ActionType: entity.ActionType,
            CurationStatus: effectiveStatus ?? CurationStatuses.Raw,
            IdempotencyKey: entity.IdempotencyKey,
            CreatedAt: entity.CreatedAt
        );
    }
}
