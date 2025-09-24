using exam_service.Contracts.Exams;
using exam_service.Data.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;

public static class AdminOptionSubEndpoint
{
    public static async Task<IResult> AddOptionHandler(
        [FromServices] ExamDbContext context, 
        [FromBody]DtoAdmin.AdminOptionUpsert dto, 
        CancellationToken token
        )
    {
        await using var transaction= await context.Database.BeginTransactionAsync(token);
        try
        {
            var existedQuestion = await context.ExamQuestions.AsNoTracking()
                .FirstOrDefaultAsync(x=>x.Id == dto.QuestionId, token);
            if (existedQuestion == null) return Results.NotFound(new ApiResultDto(false, "Question not found", null!));
            var maxIdx = await context.ExamQuestions.AsNoTracking()
                .Where(x=>x.Id == dto.QuestionId)
                .Select(x=> (int?)x.Id)
                .MaxAsync(token) ?? 0;
            var desired = dto.Idx ?? (maxIdx + 1);
            if (desired < 0) desired = 1;
            if (desired > maxIdx + 1) desired = maxIdx + 1;
            if (desired <= maxIdx) await context.ExamOptions
                .Where(x => x.QuestionId == dto.QuestionId && x.Idx >= desired)
                .ExecuteUpdateAsync(question => 
                        question.SetProperty(x=>x.Idx, x=>x.Idx + 1)
                    ,token);
            var newOption = new ExamOption()
            {
                QuestionId = dto.QuestionId,
                Idx = desired,
                IsCorrect = dto.IsCorrect, 
                ContentMd = dto.ContentMd
            };
            context.ExamOptions.Add(newOption);
            await context.SaveChangesAsync(token);
            await transaction.CommitAsync(token);
            return Results.Ok(new ApiResultDto(true, "Added option successfully", newOption));
        }
        catch (Exception e)
        {
            await transaction.RollbackAsync(token);
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
}