using exam_service.Contracts.Exams;
using exam_service.Data.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint;

public static class AdminQuestionSubEndpoint
{
    public static RouteHandlerBuilder MapAddQuestionEndpoint(this RouteGroupBuilder app)
    {
        return app.MapPost("/add", async (
                [FromServices] ExamDbContext context, 
                CancellationToken token,
                [FromBody] DtoAdmin.AdminQuestionUpsert dto
                ) =>
        {
            var existedSection = context.ExamSections.AsNoTracking().FirstOrDefault(section => section.Id==dto.SectionId);
            if (existedSection == null) return Results.BadRequest(new ApiResultDto(false, "Not found section", null!));
            await using var transaction = await context.Database.BeginTransactionAsync(token) ;
            try
            {
                var maxIdx = await context.ExamQuestions.AsNoTracking()
                    .Where(question => question.SectionId == dto.SectionId)
                    .Select(a => (int?)a.Idx).MaxAsync(token) ?? 0;
                var desired = dto.Idx ?? maxIdx + 1;
                if (desired < 1) desired = 1; 
                if (desired > maxIdx + 1) desired = maxIdx + 1;
                if (desired <= maxIdx) 
                    await context.ExamQuestions
                        .Where(x=>x.SectionId == dto.SectionId && x.Idx >= desired)
                        .ExecuteUpdateAsync( s => s.SetProperty(d => d.Idx, d => d.Idx + 1) ,token);
                var ques = new ExamQuestion()
                {
                    Difficulty = dto.Difficulty,
                    ExplanationMd = dto.ExplanationMd, 
                    Idx = desired, 
                    SectionId = dto.SectionId, 
                    Type = dto.Type, 
                    Skill = dto.Skill, 
                    PromptMd = dto.PromptMd,
                };
                context.ExamQuestions.Add(ques);
                
                await context.SaveChangesAsync(token);
                await transaction.CommitAsync(token);
                return Results.Ok(new ApiResultDto(true, "Created question successfully", null!)); 
            }
            catch ( Exception e)
            {
                await transaction.RollbackAsync(token);
                return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
            }
                                 
            
        }).AllowAnonymous()
        .Produces(StatusCodes.Status200OK).Produces(StatusCodes.Status400BadRequest); 
    }
}