using System.Security.Claims;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

public interface IAdminSectionService
{
    public Task<IResult> AddAsync(
        DtoAdmin.AdminSectionUpsert dto,
        CancellationToken token);

    public Task<IResult> UpdateAync(
        DtoAdmin.AdminSectionUpdate dto, Guid id,
        CancellationToken token);

    public Task<IResult> DeleteAsync(Guid id, CancellationToken token);

    Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token);
}

public class AdminSectionService(ExamDbContext context, IHttpContextAccessor? httpContextAccessor = null) : IAdminSectionService
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

    public async Task<IResult> AddAsync(DtoAdmin.AdminSectionUpsert dto, CancellationToken token)
    {
        var existedExam = context.Exams.AsNoTracking().FirstOrDefault(exam => exam.Id == dto.ExamId);
        if (existedExam == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));

        var meta = GetContextMetadata();

        var strategy = context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await context.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Add section successfully (Idempotent replay)", null!));
                }
            }

            var section = new ExamSection
            {
                ExamId = dto.ExamId,
                Idx = dto.Idx ?? 1,
                Title = dto.Title,
                InstructionsMd = dto.InstructionsMd,
                PassageMd = dto.PassageMd,
                AudioUrl = dto.AudioUrl,
                TranscriptMd = dto.TranscriptMd
            };

            context.ExamSections.Add(section);
            await context.SaveChangesAsync(token);
            await FeedbackService.RecordSectionAddAsync(context, section, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await context.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Add section successfully", section));
        });
    }

    public async Task<IResult> UpdateAync(DtoAdmin.AdminSectionUpdate dto, Guid id, CancellationToken token)
    {
        var meta = GetContextMetadata();

        var strategy = context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await context.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Updated 1 row (Idempotent replay)", null!));
                }
            }

            var before = await context.ExamSections.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.NotFound(new ApiResultDto(false, "Section not found", null!));

            var section = await context.ExamSections.FirstOrDefaultAsync(x => x.Id == id, token);
            if (section == null)
                return Results.NotFound(new ApiResultDto(false, "Section not found", null!));

            section.Idx = dto.Idx ?? section.Idx;
            section.Title = dto.Title;
            section.InstructionsMd = dto.InstructionsMd;
            section.PassageMd = dto.PassageMd;
            section.AudioUrl = dto.AudioUrl;
            section.TranscriptMd = dto.TranscriptMd;

            await context.SaveChangesAsync(token);
            await FeedbackService.RecordSectionEditAsync(context, before, section, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await context.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Updated 1 row", null!));
        });
    }

    public async Task<IResult> DeleteAsync(Guid id, CancellationToken token)
    {
        var meta = GetContextMetadata();

        var strategy = context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await context.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await context.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Deleted (Idempotent replay)", null!));
                }
            }

            var before = await context.ExamSections.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.Ok(new ApiResultDto(true, "Deleted 0", null!));

            await FeedbackService.RecordSectionDeleteAsync(context, before, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            var affectedRow = await context.ExamSections.Where(x => x.Id == id).ExecuteDeleteAsync(token);
            await context.SaveChangesAsync(token);
            await tx.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow}", null!));
        });
    }

    public async Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token)
    {
        var existedExam = context.Exams.AsNoTracking().FirstOrDefault(exam => exam.Id == examId);
        if (existedExam == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));

        var sections = await context.ExamSections.AsNoTracking()
            .Where(x => x.ExamId == examId)
            .OrderBy(x => x.Idx)
            .Select(x => new
            {
                x.Id,
                x.ExamId,
                x.Idx,
                x.Title,
                x.InstructionsMd,
                x.PassageMd,
                x.AudioUrl,
                x.TranscriptMd
            })
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched sections by exam id", sections));
    }
}
