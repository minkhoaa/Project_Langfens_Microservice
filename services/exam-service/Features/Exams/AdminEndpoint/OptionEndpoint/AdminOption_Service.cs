using exam_service.Contracts.Exams;
using exam_service.Data.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;

public interface IAdminOptionService
{
    public Task<IResult> AddAsync(DtoAdmin.AdminOptionUpsert dto, CancellationToken token);
    public Task<IResult> UpdateAsync(int id, DtoAdmin.AdminOptionUpdate dto, CancellationToken token);
    public Task<IResult> DeleteAsync(int id, CancellationToken token);
}

public class AdminOptionService(ExamDbContext db) : IAdminOptionService
{
    public async Task<IResult> AddAsync(DtoAdmin.AdminOptionUpsert dto, CancellationToken token)
    {
        await using var tx = await db.Database.BeginTransactionAsync(token);
        try
        {
            var existedQuestion = await db.ExamQuestions.AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == dto.QuestionId, token);
            if (existedQuestion == null)
                return Results.NotFound(new ApiResultDto(false, "Question not found", null!));

            // maxIdx phải lấy từ ExamOptions theo QuestionId, chọn cột Idx
            var maxIdx = await db.ExamOptions.AsNoTracking()
                .Where(x => x.QuestionId == dto.QuestionId)
                .Select(x => (int?)x.Idx)
                .MaxAsync(token) ?? 0;

            var desired = dto.Idx ?? maxIdx + 1;
            if (desired < 1) desired = 1;
            if (desired > maxIdx + 1) desired = maxIdx + 1;

            // nếu chèn giữa, dịch các option phía sau
            if (desired <= maxIdx)
            {
                await db.ExamOptions
                    .Where(x => x.QuestionId == dto.QuestionId && x.Idx >= desired)
                    .ExecuteUpdateAsync(q => q.SetProperty(x => x.Idx, x => x.Idx + 1), token);
            }

            var newOption = new ExamOption
            {
                QuestionId = dto.QuestionId,
                Idx = desired,
                IsCorrect = dto.IsCorrect,
                ContentMd = dto.ContentMd
            };

            db.ExamOptions.Add(newOption);
            await db.SaveChangesAsync(token);
            await tx.CommitAsync(token);

            return Results.Ok(new ApiResultDto(true, "Added option successfully", newOption));
        }
        catch (Exception e)
        {
            await tx.RollbackAsync(token);
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> UpdateAsync(int id, DtoAdmin.AdminOptionUpdate dto, CancellationToken token)
    {
        try
        {
            var effected = await db.ExamOptions
                .Where(x => x.Id == id)
                .ExecuteUpdateAsync(opt => opt
                    .SetProperty(x => x.QuestionId, dto.QuestionId)
                    .SetProperty(x => x.Idx, dto.Idx)
                    .SetProperty(x => x.ContentMd, dto.ContentMd)
                    .SetProperty(x => x.IsCorrect, dto.IsCorrect), token);

            return Results.Ok(new ApiResultDto(true, $"Updated {effected} row", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> DeleteAsync(int id, CancellationToken token)
    {
        try
        {
            var effected = await db.ExamOptions
                .Where(x => x.Id == id)
                .ExecuteDeleteAsync(token);

            return Results.Ok(new ApiResultDto(true, $"Deleted {effected} row", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
}