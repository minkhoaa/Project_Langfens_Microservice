using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using Shared.ExamDto.Contracts;

namespace exam_service.Features.QuestionBank;

public record QuestionTypeDto(string Type, int Count);

public record QuestionBankItemDto(
    Guid Id,
    int Idx,
    string Type,
    string Skill,
    int Difficulty,
    string? PromptMd,
    string? ExplanationMd,
    Guid SectionId,
    string SectionTitle,
    Guid ExamId,
    string ExamTitle,
    List<OptionDto> Options
);

public record OptionDto(Guid Id, string Text, bool IsCorrect, int Idx);

public record QuestionBankResponse(
    List<QuestionBankItemDto> Items,
    int TotalCount,
    int Page,
    int PageSize
);

public interface IQuestionBankService
{
    Task<IResult> GetQuestionTypes(string? skill, CancellationToken token);
    Task<IResult> GetQuestionsByType(string type, string? skill, int page, int pageSize, CancellationToken token);
    Task<IResult> GetExamByQuestionTypes(string? type, int page, int pageSize, CancellationToken token);
}

public class QuestionBankService(ExamDbContext context) : IQuestionBankService
{
    public async Task<IResult> GetQuestionTypes(string? skill, CancellationToken token)
    {
        var query = context.ExamQuestions.AsNoTracking();

        if (!string.IsNullOrEmpty(skill))
            query = query.Where(q => q.Skill.ToUpper() == skill.ToUpper());
        
        var types = await query
            .GroupBy(q => q.Type)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .Select(x => new QuestionTypeDto(x.Type, x.Count))
            .ToListAsync(token);

        return Results.Ok(new ApiResultDto(true, "Question types fetched", types));
    }
    public async Task<IResult> GetExamByQuestionTypes(string? type, int page, int pageSize, CancellationToken token)
    {
        var exams = await context.Exams.AsNoTracking()
            .Where(e => context.ExamQuestions.Any(q => q.Section.ExamId == e.Id && q.Type == type))
            .Skip((page -1) * pageSize)
            .Take(pageSize)
            .Select(k => new Dto_Public.PublicExamRecord(k.Id, k.Slug, k.Title, k.Category, k.Level, k.DurationMin,
                k.UpdatedAt, k.ImageUrl!)).ToListAsync(token);
        return Results.Ok(new ApiResultDto(true, "Fetched successfully", exams));
    }

    public async Task<IResult> GetQuestionsByType(string type, string? skill, int page, int pageSize, CancellationToken token)
    {
        pageSize = Math.Clamp(pageSize, 1, 50);
        page = Math.Max(1, page);
        
        var query = context.ExamQuestions.AsNoTracking()
            .Include(q => q.Options)
            .Include(q => q.Section)
            .ThenInclude(s => s.Exam)
            .Where(q => q.Type.ToUpper() == type.ToUpper());
        
        if (!string.IsNullOrEmpty(skill))
            query = query.Where(q => q.Skill.ToUpper() == skill.ToUpper());
        
        var totalCount = await query.CountAsync(token);
        
        var items = await query
            .OrderBy(q => q.Section.Exam.Title)
            .ThenBy(q => q.Idx)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(q => new QuestionBankItemDto(
                q.Id,
                q.Idx,
                q.Type,
                q.Skill,
                q.Difficulty,
                q.PromptMd,
                q.ExplanationMd,
                q.SectionId,
                q.Section.Title ?? "",
                q.Section.ExamId,
                q.Section.Exam.Title,
                q.Options.OrderBy(o => o.Idx).Select(o => new OptionDto(o.Id, o.ContentMd, o.IsCorrect, o.Idx)).ToList()
            ))
            .ToListAsync(token);
        
        return Results.Ok(new ApiResultDto(true, "Questions fetched", new QuestionBankResponse(items, totalCount, page, pageSize)));
    }
}

