using System.Security.Claims;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.ReadingPaper;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;

public interface IAdminOptionService
{
    public Task<IResult> AddAsync(DtoAdmin.AdminOptionUpsert dto, CancellationToken token);
    public Task<IResult> UpdateAsync(Guid id, DtoAdmin.AdminOptionUpdate dto, CancellationToken token);
    public Task<IResult> DeleteAsync(Guid id, CancellationToken token);

    Task<IResult> GetByQuestionIdAsync(Guid questionId, CancellationToken token);
}

public class AdminOptionService(ExamDbContext db, IHttpContextAccessor? httpContextAccessor = null) : IAdminOptionService
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

    public async Task<IResult> AddAsync(DtoAdmin.AdminOptionUpsert dto, CancellationToken token)
    {
        var existedQuestion = await db.ExamQuestions.AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == dto.QuestionId, token);
        if (existedQuestion == null)
            return Results.NotFound(new ApiResultDto(false, "Question not found", null!));

        var meta = GetContextMetadata();

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Add option successfully (Idempotent replay)", null!));
                }
            }

            var option = new ExamOption
            {
                QuestionId = dto.QuestionId,
                ContentMd = dto.ContentMd,
                Idx = dto.Idx ?? 1,
                IsCorrect = dto.IsCorrect,
                AltText = dto.AltText,
                ImageUrl = dto.ImageUrl
            };

            db.ExamOptions.Add(option);
            await db.SaveChangesAsync(token);
            await FeedbackService.RecordOptionAddAsync(db, option, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await db.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Add option successfully", option));
        });
    }

    public async Task<IResult> UpdateAsync(Guid id, DtoAdmin.AdminOptionUpdate dto, CancellationToken token)
    {
        var meta = GetContextMetadata();

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Updated 1 row (Idempotent replay)", null!));
                }
            }

            var before = await db.ExamOptions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.NotFound(new ApiResultDto(false, "Option not found", null!));

            var option = await db.ExamOptions.FirstOrDefaultAsync(x => x.Id == id, token);
            if (option == null)
                return Results.NotFound(new ApiResultDto(false, "Option not found", null!));

            option.ContentMd = dto.ContentMd;
            option.Idx = dto.Idx ?? option.Idx;
            option.IsCorrect = dto.IsCorrect;
            option.AltText = dto.AltText;
            option.ImageUrl = dto.ImageUrl;

            await db.SaveChangesAsync(token);
            await FeedbackService.RecordOptionEditAsync(db, before, option, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            await db.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Updated 1 row", null!));
        });
    }

    public async Task<IResult> DeleteAsync(Guid id, CancellationToken token)
    {
        var meta = GetContextMetadata();

        var strategy = db.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(token);

            if (!string.IsNullOrEmpty(meta.idempotencyKey))
            {
                var existingFeedback = await db.ReadingPaperHumanFeedbacks.AsNoTracking()
                    .FirstOrDefaultAsync(f => f.IdempotencyKey == meta.idempotencyKey, token);
                if (existingFeedback != null)
                {
                    return Results.Ok(new ApiResultDto(true, "Deleted (Idempotent replay)", null!));
                }
            }

            var before = await db.ExamOptions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, token);
            if (before == null)
                return Results.Ok(new ApiResultDto(true, "Deleted 0", null!));

            await FeedbackService.RecordOptionDeleteAsync(db, before, meta.editorId, meta.editorRole, meta.reasons, meta.comment, meta.idempotencyKey, token);
            var affectedRow = await db.ExamOptions.Where(x => x.Id == id).ExecuteDeleteAsync(token);
            await db.SaveChangesAsync(token);
            await tx.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow}", null!));
        });
    }

    public async Task<IResult> GetByQuestionIdAsync(Guid questionId, CancellationToken token)
    {
        var options = await db.ExamOptions.AsNoTracking()
            .Where(x => x.QuestionId == questionId)
            .OrderBy(x => x.Idx)
            .Select(x => new
            {
                x.Id,
                x.QuestionId,
                x.Idx,
                x.ContentMd,
                x.IsCorrect,
                x.ImageUrl,
                x.AltText
            })
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Fetched options by question id", options));
    }
}
