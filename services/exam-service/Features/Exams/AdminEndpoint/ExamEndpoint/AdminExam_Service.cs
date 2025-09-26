using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Domains.Enums;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;

public interface IAdminExamService
{
    public Task<IResult> AddAsync(DtoAdmin.AdminExamCreate dto, CancellationToken ct = default);
    public Task<IResult> UpdateAsync(int id, DtoAdmin.AdminExamUpdate dto, CancellationToken ct = default);
    public Task<IResult> DeleteAsync(int id, CancellationToken ct = default);
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
        var now = DateTimeOffset.UtcNow;

        var exam = new Exam
        {
            Slug = slug, Title = dto.Title, DescriptionMd = dto.DescriptionMd,
            Category = dto.Category, Level = dto.Level, Status = ExamStatus.Draft,
            DurationMin = dto.DurationMin, CreatedAt = now, UpdatedAt = now
        };

        db.Exams.Add(exam);
        await db.SaveChangesAsync(ct);
        return Results.Ok(new ApiResultDto(true, "Create successfully", exam));
    }

    public async Task<IResult> UpdateAsync(int id, DtoAdmin.AdminExamUpdate dto, CancellationToken ct = default)
    {
        var affected = await db.Exams.Where(x => x.Id == id).ExecuteUpdateAsync(x => x
            .SetProperty(e => e.Title, dto.Title)
            .SetProperty(e => e.DescriptionMd, dto.DescriptionMd)
            .SetProperty(e => e.Category, dto.Category)
            .SetProperty(e => e.Level, dto.Level)
            .SetProperty(e => e.DurationMin, dto.DurationMin)
            .SetProperty(e => e.Status, dto.Status)
            .SetProperty(e => e.UpdatedAt, DateTimeOffset.UtcNow), ct);

        return Results.Ok(new ApiResultDto(true, $"Affected {affected} rows", null!));
    }

    public async Task<IResult> DeleteAsync(int id, CancellationToken ct = default)
    {
        var affected = await db.Exams.Where(e => e.Id == id).ExecuteDeleteAsync(ct);
        return Results.Ok(new ApiResultDto(true, $"Deleted {affected}", null!));
    }
}