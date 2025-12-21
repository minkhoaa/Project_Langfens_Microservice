using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
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

public class AdminSectionService(ExamDbContext context) : IAdminSectionService
{
    public async Task<IResult> AddAsync(DtoAdmin.AdminSectionUpsert dto, CancellationToken token)
    {
        var existedExam = context.Exams.AsNoTracking().FirstOrDefault(exam => exam.Id == dto.ExamId);
        if (existedExam == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));

        await using var transaction = await context.Database.BeginTransactionAsync(token);
        try
        {
            var maxIdx = await context.ExamSections.AsNoTracking().Where(x => x.ExamId == dto.ExamId)
                .Select(x => (int?)x.Idx).MaxAsync(token) ?? 0;
            var desired = dto.Idx ?? maxIdx + 1;
            if (desired < 1) desired = 1;
            if (desired > maxIdx + 1) desired = maxIdx + 1;
            if (desired <= maxIdx)
            {
                await context.ExamSections.Where(x => x.ExamId == dto.ExamId && x.Idx >= desired)
                    .ExecuteUpdateAsync(x => x.SetProperty(section => section.Idx, section => section.Idx + 1), token);
            }

            var sec = new ExamSection
            {
                ExamId = dto.ExamId,
                Idx = desired,
                InstructionsMd = dto.InstructionsMd,
                PassageMd = dto.PassageMd,
                Title = dto.Title,
                AudioUrl = dto.AudioUrl,
                TranscriptMd = dto.TranscriptMd
            };
            context.ExamSections.Add(sec);
            var now = DateTime.UtcNow;
            await context.Exams.Where(x => x.Id == dto.ExamId)
                .ExecuteUpdateAsync(
                    s => s.SetProperty(e => e.UpdatedAt, now),
                    token);
            await context.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, "Added successfully", sec));
        }
        catch (Exception e)
        {
            await transaction.RollbackAsync(token);
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> UpdateAync(DtoAdmin.AdminSectionUpdate dto, Guid id, CancellationToken token)
    {
        try
        {
            var targetExamId = dto.ExamId;
            var targetIdx = dto.Idx;
            var targetTitle = dto.Title;
            var targetInstructions = dto.InstructionsMd;

            var effectedRow = await context.ExamSections.Where(section => section.Id == id)
                .ExecuteUpdateAsync(
                    section => section
                        .SetProperty(s => s.ExamId, dto.ExamId)
                        .SetProperty(s => s.Idx, dto.Idx)
                        .SetProperty(s => s.Title, dto.Title)
                        .SetProperty(s => s.InstructionsMd, dto.InstructionsMd)
                        .SetProperty(s => s.PassageMd, dto.PassageMd)
                        .SetProperty(s => s.AudioUrl, dto.AudioUrl)
                        .SetProperty(s => s.TranscriptMd, dto.TranscriptMd),
                    token);

            return Results.Ok(new ApiResultDto(true, $"Update {effectedRow}", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> DeleteAsync(Guid id, CancellationToken token)
    {
        try
        {
            var deletedRow = await context.ExamSections.Where(x => x.Id == id)
                .ExecuteDeleteAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {deletedRow}", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token)
    {
        var sections = await context.ExamSections.AsNoTracking()
            .Where(s => s.ExamId == examId)
            .OrderBy(s => s.Idx)
            .Select(s => new
            {
                s.Id,
                s.ExamId,
                s.Idx,
                s.Title,
                s.InstructionsMd,
                s.PassageMd,
                s.AudioUrl,
                s.TranscriptMd
            })
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Success", sections));
    }
}
