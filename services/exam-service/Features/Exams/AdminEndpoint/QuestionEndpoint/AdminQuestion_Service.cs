using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;

public interface IAdminQuestionService
{
    public Task<IResult> AddAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpsert dto
    );

    public Task<IResult> UpdateAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpdate dto,
        [FromRoute] int id
    );

    public Task<IResult> DeleteAsync(
        CancellationToken token,
        [FromRoute] int id);
}

public class AdminQuestionService : IAdminQuestionService
{
    private readonly ExamDbContext _context;
    public AdminQuestionService(ExamDbContext context) => _context = context;

    public async Task<IResult> AddAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpsert dto
    )
    {
        var existedSection =
            _context.ExamSections.AsNoTracking().FirstOrDefault(section => section.Id == dto.SectionId);
        if (existedSection == null) return Results.BadRequest(new ApiResultDto(false, "Not found section", null!));
        await using var transaction = await _context.Database.BeginTransactionAsync(token);
        try
        {
            var maxIdx = await _context.ExamQuestions.AsNoTracking()
                .Where(question => question.SectionId == dto.SectionId)
                .Select(a => (int?)a.Idx).MaxAsync(token) ?? 0;
            var desired = dto.Idx ?? maxIdx + 1;
            if (desired < 1) desired = 1;
            if (desired > maxIdx + 1) desired = maxIdx + 1;
            if (desired <= maxIdx)
                await _context.ExamQuestions
                    .Where(x => x.SectionId == dto.SectionId && x.Idx >= desired)
                    .ExecuteUpdateAsync(s => s.SetProperty(d => d.Idx, d => d.Idx + 1), token);
            var ques = new ExamQuestion
            {
                Difficulty = dto.Difficulty,
                ExplanationMd = dto.ExplanationMd,
                Idx = desired,
                SectionId = dto.SectionId,
                Type = dto.Type,
                Skill = dto.Skill,
                PromptMd = dto.PromptMd
            };
            _context.ExamQuestions.Add(ques);

            await _context.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, "Created question successfully", ques));
        }
        catch (Exception e)
        {
            await transaction.RollbackAsync(token);
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> UpdateAsync(
        CancellationToken token,
        [FromBody] DtoAdmin.AdminQuestionUpdate dto,
        [FromRoute] int id
    )
    {
        try
        {
            var affectedRow = await _context.ExamQuestions.Where(x => x.Id == id)
                .ExecuteUpdateAsync(question => question
                        .SetProperty(x => x.SectionId, dto.SectionId)
                        .SetProperty(x => x.Idx, dto.Idx)
                        .SetProperty(x => x.Type, dto.Type)
                        .SetProperty(x => x.Skill, dto.Skill)
                        .SetProperty(x => x.Difficulty, dto.Difficulty)
                        .SetProperty(x => x.PromptMd, dto.PromptMd)
                        .SetProperty(x => x.ExplanationMd, dto.ExplanationMd)
                    , token);
            return Results.Ok(new ApiResultDto(true, $"Updated {affectedRow} row", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> DeleteAsync(
        CancellationToken token,
        [FromRoute] int id)
    {
        try
        {
            var affectedRow = await _context.ExamQuestions.Where(x => x.Id == id)
                .ExecuteDeleteAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow}", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
}