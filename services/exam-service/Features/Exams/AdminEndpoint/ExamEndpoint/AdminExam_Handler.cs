using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Domains.Enums;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;

public static class AdminExamSubEndpoint
{   
    public static async Task<IResult> AddExamHandler([FromBody] DtoAdmin.AdminExamCreate dto,
        CancellationToken token, 
        [FromServices] ExamDbContext context)
    {
        if (string.IsNullOrWhiteSpace(dto.Title)) 
            return Results.BadRequest(new ApiResultDto(false, "Title is required", null!));
            
        var baseSlug = !string.IsNullOrWhiteSpace(dto.Slug)
            ? SlugHelper.ToSlug(dto.Slug)
            : SlugHelper.ToSlug(dto.Title);

        if (string.IsNullOrWhiteSpace(baseSlug)) 
            return Results.BadRequest(new ApiResultDto(false, "Cannot generate slug", null!));
        var uniqueSlug = await SlugHelper.MakeUniqueSlugAsync(context, baseSlug, token); 
        var newExam = new Exam()
        {
            Slug = uniqueSlug, 
            Category = dto.Category,
            Title = dto.Title,
            DescriptionMd = dto.DescriptionMd,
            Level = dto.Level,
            Status = ExamStatus.Draft,
            DurationMin = dto.DurationMin, 
            CreatedAt = DateTimeOffset.UtcNow,
            UpdatedAt = DateTimeOffset.UtcNow
        };
        context.Exams.Add(newExam);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Create successfully", newExam));
    }
    
    
    public static RouteHandlerBuilder UpdateExamEndpoint(this RouteGroupBuilder app)
    {
        return app.MapPut("/update{id}", async ([FromRoute] int id,
                [FromServices] ExamDbContext context,
                [FromBody] DtoAdmin.AdminExamUpdate update) =>
        {
           try {
            var effectedExam =  await context.Exams.Where(x=> x.Id == id).ExecuteUpdateAsync(x=>
                    x.SetProperty(exam =>exam.Title, update.Title)
                        .SetProperty(exam=>exam.DescriptionMd, update.DescriptionMd)
                        .SetProperty(exam=>exam.Category, update.Category)
                        .SetProperty(exam=>exam.Level, update.Title)
                        .SetProperty(exam=>exam.DurationMin, update.DurationMin)
                        .SetProperty(exam=>exam.Status, update.Status)
                    );
            return Results.Ok(new ApiResultDto(true, $"Affected {effectedExam} rows", null!));
           } catch (Exception e)
           {
               return Results.BadRequest(new ApiResultDto(false,"Failed: " +  e.Message, null!));
           }
            
        }).AllowAnonymous()
        .Produces(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .Produces(StatusCodes.Status400BadRequest);
    }
    public static RouteHandlerBuilder DeleteExamEndpoint(this RouteGroupBuilder app)
    {
        return app.MapDelete("/delete{id}", async ([FromRoute] int id,
                [FromServices] ExamDbContext context) =>
        {
            try
            {
                var affectedRow = await context.Exams.Where(exam => exam.Id == id).ExecuteDeleteAsync();
                return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow}", null!));
            }
            catch ( Exception e)
            {
                return Results.BadRequest(new ApiResultDto(false,"Failed: " +  e.Message, null!));
            }
        }).AllowAnonymous()
        .Produces(StatusCodes.Status200OK)
        .Produces(StatusCodes.Status404NotFound)
        .Produces(StatusCodes.Status400BadRequest);
    } 
}