using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;

public static class AdminSectionSubEndpoint
{
    public static RouteHandlerBuilder AddSectionSubEndpoint(this RouteGroupBuilder app)
    {
        return app.MapPost("/add", async (
                [FromServices] ExamDbContext context, 
                [FromBody] DtoAdmin.AdminSectionUpsert dto,
                CancellationToken token
                ) => 
        {
            var existedExam = context.Exams.AsNoTracking().FirstOrDefault(exam => exam.Id == dto.ExamId); 
            if (existedExam == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));
            
            await using var transaction = await context.Database.BeginTransactionAsync(token);
            try {
                var maxIdx = await context.ExamSections.AsNoTracking().Where(x=>x.ExamId == dto.ExamId)
                    .Select(x=>(int?)x.Idx).MaxAsync(token) ?? 0 ;
                var desired = dto.Idx ?? (maxIdx + 1);
                if (desired < 1) desired = 1; 
                if (desired > maxIdx + 1) desired = maxIdx + 1;
                if (desired <= maxIdx)
                {
                    await context.ExamSections.Where(x=> x.ExamId == dto.ExamId && x.Idx >= desired)
                        .ExecuteUpdateAsync(x=> x.SetProperty(section=> section.Idx, section=>section.Idx + 1), token);
                }
                var sec = new ExamSection()
                {
                    ExamId = dto.ExamId,
                    Idx = desired, 
                    InstructionsMd = dto.InstructionsMd,
                    Title = dto.Title
                };
                context.ExamSections.Add(sec);
                await context.Exams.Where(x=> x.Id == dto.ExamId)
                    .ExecuteUpdateAsync(
                        s => s.SetProperty(e => e.UpdatedAt, DateTimeOffset.UtcNow),
                        token);
                await context.SaveChangesAsync(token); 
                await transaction.CommitAsync(token);
                return Results.Ok(new ApiResultDto(true, "Added successfully", null!)); 
            }
            catch (Exception e)
            {
                await transaction.RollbackAsync(token);
                return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
            }
        }).AllowAnonymous()
            .Produces(StatusCodes.Status400BadRequest)
            .Produces(StatusCodes.Status404NotFound);  
     
    }
    public static RouteHandlerBuilder UpdateSectionSubEndpoint(this RouteGroupBuilder app)
    {
        
    }
}