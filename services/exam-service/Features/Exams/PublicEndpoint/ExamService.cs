using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Application.Exam;

public interface IExamService
{
    // public
    Task<IResult> ListPublishedAsync(string? category, string? level, int page, int pageSize,
        CancellationToken cancellationToken);

    Task<IResult> GetBySlugAsync(string slug, CancellationToken cancellationToken);
}

public class ExamService : IExamService
{
    private readonly ExamDbContext _context;

    public ExamService(ExamDbContext context)
    {
        _context = context;
    }

    public async Task<IResult> ListPublishedAsync(string? category, string? level, int page, int pageSize,
        CancellationToken cancellationToken)
    {
        try {
            var exams = _context.Exams.AsNoTracking().Where(x => x.Status == ExamStatus.Published);
            if (!string.IsNullOrWhiteSpace(category))
                exams = exams.Where(x => x.Category == category);
            if (!string.IsNullOrWhiteSpace(level))
                exams = exams.Where(x => x.Level == level);
            var items = await exams.OrderByDescending(x => x.UpdatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(x =>
                    new Dto_Public.PublicExamRecord(
                        x.Id, x.Slug, x.Title, x.Category, x.Level, x.DurationMin, x.UpdatedAt
                    ))
                .ToListAsync(cancellationToken: cancellationToken);
        
            return (items != null) ?  Results.Ok(new ApiResultDto(true, "Success", items)) : Results.NotFound(new ApiResultDto(false, "Not found", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> GetBySlugAsync(string slug, CancellationToken cancellationToken)
    {
        try
        {
            var exams = await _context.Exams.AsNoTracking()
                .Where(x => x.Slug == slug)
                .Select(exam => new Dto_Public.PubLicExamDetailRecord(
                    exam.Id, exam.Slug, exam.Title, exam.DescriptionMd, exam.Category, exam.Level, exam.DurationMin,
                    exam.Sections
                        .OrderBy(s => s.Idx)
                        .Select(section => new Dto_Public.PublicSectionRecord(
                            section.Idx, section.Title, section.InstructionsMd,
                            section.Questions
                                .OrderBy(d => d.Idx)
                                .Select(question =>
                                    new Dto_Public.PublicQuestionRecord(
                                        question.Idx, question.Type, question.Skill,
                                        question.Difficulty, question.PromptMd,
                                        question.Options
                                            .OrderBy(option => option.Idx)
                                            .Select(option =>
                                                new Dto_Public.PublicOptionRecord(option.Idx, option.ContentMd))
                                            .ToList()
                                    )).ToList()
                        )).ToList()
                )).FirstOrDefaultAsync(cancellationToken);
            return (exams == null) ? Results.NotFound( new ApiResultDto(false, "Not found", null!)) 
                : Results.Ok(new ApiResultDto(true, "Success", exams));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
}