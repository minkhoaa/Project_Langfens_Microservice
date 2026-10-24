using System.Security.Claims;
using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;

public interface IAdminExamService
{
    public Task<IResult> AddAsync(DtoAdmin.AdminExamCreate dto, CancellationToken ct = default);
    public Task<IResult> UpdateAsync(Guid id, DtoAdmin.AdminExamUpdate dto, CancellationToken ct = default);
    public Task<IResult> DeleteAsync(Guid id, CancellationToken ct = default);
    public Task<IResult> ListAllAsync(CancellationToken ct = default);
}

public sealed class AdminExamService(ExamDbContext db, IHttpContextAccessor? httpContextAccessor = null) : IAdminExamService
{
    private (string editorId, string editorRole, string? idempotencyKey, string[]? reasons, string? comment) GetContextMetadata()
    {
        var httpContext = httpContextAccessor?.HttpContext;
        var user = httpContext?.User;
        var editorId = user?.FindFirstValue("sub") ?? user?.FindFirstValue(ClaimTypes.NameIdentifier) ?? "admin";
        var editorRole = user?.FindFirstValue("role") ?? user?.FindFirstValue(ClaimTypes.Role) ?? "ADMIN";
        var idempotencyKey = httpContext?.Request.Headers["Idempotency-Key"].FirstOrDefault()
                          ?? httpContext?.Request.Headers["X-Idempotency-Key"].FirstOrDefault();
        var reasonsHeader = httpContext?.Request.Headers["X-Feedback-Reasons"].FirstOrDefault();
        var reasons = !string.IsNullOrWhiteSpace(reasonsHeader)
            ? reasonsHeader.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            : null;
        var comment = httpContext?.Request.Headers["X-Feedback-Comment"].FirstOrDefault();
        return (editorId, editorRole, idempotencyKey, reasons, comment);
    }

    public async Task<IResult> AddAsync(DtoAdmin.AdminExamCreate dto, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
            return Results.BadRequest(new ApiResultDto(false, "Title is required", null!));

        var meta = GetContextMetadata();
        if (!string.IsNullOrEmpty(meta.idempotencyKey))
        {
            var existing = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, ct);
            if (existing != null)
                return Results.Ok(new ApiResultDto(true, "Created (Idempotent replay)", null!));
        }

        var baseSlug = string.IsNullOrWhiteSpace(dto.Slug) ? SlugHelper.ToSlug(dto.Title) : SlugHelper.ToSlug(dto.Slug);
        if (string.IsNullOrWhiteSpace(baseSlug))
            return Results.BadRequest(new ApiResultDto(false, "Cannot generate slug", null!));

        var slug = await SlugHelper.MakeUniqueSlugAsync(db, baseSlug, ct);
        var now = DateTime.UtcNow;

        var exam = new Exam
        {
            Slug = slug,
            Title = dto.Title,
            DescriptionMd = dto.DescriptionMd,
            Category = dto.Category,
            Level = dto.Level,
            Status = ExamStatus.Draft,
            DurationMin = dto.DurationMin,
            CreatedAt = now,
            UpdatedAt = now,
            ImageUrl = dto.ImageUrl
        };

        db.Exams.Add(exam);
        await db.SaveChangesAsync(ct);
        return Results.Ok(new ApiResultDto(true, "Create successfully", exam));
    }

    public async Task<IResult> UpdateAsync(Guid id, DtoAdmin.AdminExamUpdate dto, CancellationToken ct = default)
    {
        var meta = GetContextMetadata();

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            // 1. Check idempotency BEFORE mutation
            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, ct);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Updated 1 row (Idempotent replay)", null!));
                }
            }

            // 2. Capture before state inside transaction
            var before = await db.Exams.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
            if (before == null)
                return Results.NotFound(new ApiResultDto(false, "Exam not found", null!));

            var exam = await db.Exams.FirstOrDefaultAsync(x => x.Id == id, ct);
            if (exam == null)
                return Results.NotFound(new ApiResultDto(false, "Exam not found", null!));

            exam.Title = dto.Title;
            exam.DescriptionMd = dto.DescriptionMd;
            exam.Category = dto.Category;
            exam.Level = dto.Level;
            exam.DurationMin = dto.DurationMin;
            if (!string.IsNullOrWhiteSpace(dto.Status))
            {
                var normalizedStatus = dto.Status.Trim().ToUpperInvariant();
                if (normalizedStatus is not (ExamStatus.Draft or ExamStatus.Published or ExamStatus.Archived))
                {
                    return Results.BadRequest(new ApiResultDto(false, $"Invalid exam status: '{dto.Status}'. Allowed values: DRAFT, PUBLISHED, ARCHIVED", null!));
                }
                if (normalizedStatus == ExamStatus.Published)
                {
                    var isBenchmarkExam = await db.ReadingPaperRuns.AsNoTracking()
                        .AnyAsync(r => db.ReadingPaperJobs.Any(j => j.ExamId == exam.Id && (j.Id == r.JobId || j.ActiveRunId == r.RunId))
                                       && !string.IsNullOrWhiteSpace(r.BenchmarkCampaignId), ct);
                    if (isBenchmarkExam)
                    {
                        return Results.Json(new ApiResultDto(false, "RESEARCH_PUBLICATION_FORBIDDEN: Research benchmark runs cannot be published to production.", null!), statusCode: 403);
                    }

                    var pubExam = await db.Exams.AsNoTracking()
                        .Include(e => e.Sections)
                            .ThenInclude(s => s.Questions)
                                .ThenInclude(q => q.Options)
                        .FirstOrDefaultAsync(e => e.Id == exam.Id, ct);
                    if (pubExam != null)
                    {
                        var pubErrors = ExamPublicationValidator.ValidateForPublication(pubExam);
                        if (pubErrors.Count > 0)
                        {
                            return Results.BadRequest(new ApiResultDto(
                                false,
                                "EXAM_PUBLICATION_VALIDATION_FAILED: Cannot publish exam with defective questions.",
                                pubErrors));
                        }
                    }
                }
                exam.Status = normalizedStatus;
            }
            exam.ImageUrl = dto.ImageUrl;
            exam.UpdatedAt = DateTime.UtcNow;

            await db.SaveChangesAsync(ct);
            await FeedbackService.RecordExamEditAsync(db, before, exam, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, ct);
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return Results.Ok(new ApiResultDto(true, "Affected 1 rows", null!));
        });
    }

    public async Task<IResult> DeleteAsync(Guid id, CancellationToken ct = default)
    {
        var meta = GetContextMetadata();

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(ct);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, ct);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Deleted (Idempotent replay)", null!));
                }
            }

            var before = await db.Exams.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
            if (before == null)
                return Results.Ok(new ApiResultDto(true, "Deleted 0", null!));

            await FeedbackService.RecordExamDeleteAsync(db, before, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, ct);
            var affected = await db.Exams.Where(e => e.Id == id).ExecuteDeleteAsync(ct);
            await db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affected}", null!));
        });
    }

    public async Task<IResult> ListAllAsync(CancellationToken ct = default)
    {
        var exams = await db.Exams.AsNoTracking()
            .OrderByDescending(x => x.UpdatedAt ?? x.CreatedAt)
            .Select(x => new
            {
                x.Id,
                x.Slug,
                x.Title,
                x.Category,
                x.Level,
                x.Status,
                x.DurationMin,
                x.CreatedAt,
                x.UpdatedAt
            })
            .ToListAsync(ct);

        return Results.Ok(new ApiResultDto(true, "Fetched all exams", exams));
    }
}
