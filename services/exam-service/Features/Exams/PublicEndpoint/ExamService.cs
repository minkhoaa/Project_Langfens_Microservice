using exam_service.Application.Common;
using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using exam_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace exam_service.Features.Exams.PublicEndpoint;

public interface IExamService
{
    // public
    Task<IResult> ListPublishedAsync(string? category, string? level, string? questionTypes, int page, int pageSize,
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

    public async Task<IResult> ListPublishedAsync(
        string? category, 
        string? level, 
        string? questionTypes,
        int page, 
        int pageSize,
        CancellationToken cancellationToken)
    {
        try
        {
            var exams = _context.Exams.AsNoTracking()
                .Where(x => x.Status == ExamStatus.Published);
            
            if (!string.IsNullOrWhiteSpace(category))
                exams = exams.Where(x => x.Category == category);
            if (!string.IsNullOrWhiteSpace(level))
                exams = exams.Where(x => x.Level == level);
            
            // Filter by question types if provided (comma-separated)
            if (!string.IsNullOrWhiteSpace(questionTypes))
            {
                var typeList = questionTypes.Split(',')
                    .Select(t => t.Trim().ToUpper())
                    .Where(t => !string.IsNullOrEmpty(t))
                    .ToList();
                
                if (typeList.Count > 0)
                {
                    exams = exams.Where(e => 
                        e.Sections.Any(s => s.Questions.Any(q => typeList.Contains(q.Type.ToUpper()))));
                }
            }
            
            var items = await exams.OrderByDescending(x => x.UpdatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(x =>
                    new Dto_Public.PublicExamRecord(
                        x.Id, x.Slug, x.Title, x.Category, x.Level, x.DurationMin, 
                        x.UpdatedAt, x.ImageUrl!,
                        x.Sections.SelectMany(s => s.Questions.Select(q => q.Type))
                            .Distinct().ToList()
                    ))
                .ToListAsync(cancellationToken: cancellationToken);

            return items != null
                ? Results.Ok(new ApiResultDto(true, "Success", items))
                : Results.NotFound(new ApiResultDto(false, "Not found", null!));
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
            var exam = await _context.Exams.AsNoTracking()
                .Include(e => e.Sections).ThenInclude(s => s.Questions).ThenInclude(q => q.Options)
                .Include(e => e.Sections).ThenInclude(s => s.QuestionGroups)
                .FirstOrDefaultAsync(x => x.Slug == slug && x.Status == ExamStatus.Published, cancellationToken);
            if (exam == null) return Results.NotFound(new ApiResultDto(false, "Not found", null!));
            var delivery = new Dto_Public.PubLicExamDetailRecord(
                exam.Id, exam.Slug, exam.Title, exam.DescriptionMd, exam.Category, exam.Level,
                exam.DurationMin, exam.ImageUrl!,
                exam.Sections.OrderBy(s => s.Idx).Select(section => new Dto_Public.PublicSectionRecord(
                    section.Idx, section.Title, section.InstructionsMd, section.PassageMd,
                    section.AudioUrl, section.TranscriptMd, [],
                    ExamDeliveryLayout.Groups(section).Select(group => new Dto_Public.PublicQuestionGroupRecord(
                        group.Id, group.Idx, group.StartIdx, group.EndIdx, group.InstructionMd,
                        group.Questions.Select(MapQuestion).ToList())).ToList())).ToList());
            return Results.Ok(new ApiResultDto(true, "Success", PaperWideNormalizer.Normalize(delivery)));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    private static Dto_Public.PublicQuestionRecord MapQuestion(ExamQuestion question) => new(
        question.Id, question.Idx, question.Type, question.Skill, question.Difficulty,
        question.PromptMd, question.ImageUrl,
        question.Options.OrderBy(o => o.Idx).Select(o => new Dto_Public.PublicOptionRecord(
            o.Idx, o.ContentMd, o.ImageUrl, o.AltText)).ToList(),
        question.WordList,
        ExamDeliveryLayout.FlowKeys(question.OrderCorrects).Select(key =>
            new Dto_Public.PublicFlowChartNode(key, key.Replace("-", " ").Trim())).ToList());
}
