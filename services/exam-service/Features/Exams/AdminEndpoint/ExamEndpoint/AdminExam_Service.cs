using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
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

public sealed class AdminExamService(ExamDbContext db) : IAdminExamService
{
    public async Task<IResult> AddAsync(DtoAdmin.AdminExamCreate dto, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
            return Results.BadRequest(new ApiResultDto(false, "Title is required", null!));

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
            UpdatedAt = now
        };

        db.Exams.Add(exam);
        await db.SaveChangesAsync(ct);
        return Results.Ok(new ApiResultDto(true, "Create successfully", exam));
    }

    public async Task<IResult> UpdateAsync(Guid id, DtoAdmin.AdminExamUpdate dto, CancellationToken ct = default)
    {
        var affected = await db.Exams.Where(x => x.Id == id).ExecuteUpdateAsync(x => x
            .SetProperty(e => e.Title, dto.Title)
            .SetProperty(e => e.DescriptionMd, dto.DescriptionMd)
            .SetProperty(e => e.Category, dto.Category)
            .SetProperty(e => e.Level, dto.Level)
            .SetProperty(e => e.DurationMin, dto.DurationMin)
            .SetProperty(e => e.Status, dto.Status)
            .SetProperty(e => e.UpdatedAt, DateTime.UtcNow), ct);

        return Results.Ok(new ApiResultDto(true, $"Affected {affected} rows", null!));
    }

    public async Task<IResult> DeleteAsync(Guid id, CancellationToken ct = default)
    {
        var affected = await db.Exams.Where(e => e.Id == id).ExecuteDeleteAsync(ct);
        return Results.Ok(new ApiResultDto(true, $"Deleted {affected}", null!));
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
