using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using exam_service.Application.Common;
using exam_service.Domains.Entities;

namespace exam_service.Features.Exams.InternalEndpoint;

public interface IInternalExamService
{
    Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token, bool showAnswer);
}

public class InternalExamService : IInternalExamService
{
    private readonly ExamDbContext _context;
    public InternalExamService(ExamDbContext context) => _context = context;

    public async Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token, bool showAnswer)
    {
        try
        {
            var exam = await _context.Exams.AsNoTracking()
                .Include(x => x.Sections).ThenInclude(s => s.Questions).ThenInclude(q => q.Options)
                .Include(x => x.Sections).ThenInclude(s => s.QuestionGroups)
                .FirstOrDefaultAsync(x => x.Id == examId, token);
            if (exam == null)
                return Results.NotFound(new ApiResultDto(false, "Not found", null!));

            var sections = exam.Sections.Where(s => s.ExamId == exam.Id).OrderBy(s => s.Idx)
                .Select(section => new InternalExamDto.InternalDeliverySection(
                    section.Idx, section.Title, section.InstructionsMd, section.PassageMd,
                    section.AudioUrl, section.TranscriptMd, [],
                    ExamDeliveryLayout.Groups(section).Select(group => new InternalExamDto.InternalDeliveryQuestionGroup(
                        group.Id, group.Idx, group.StartIdx, group.EndIdx, group.InstructionMd,
                        group.Questions.Select(q => MapQuestion(q, showAnswer)).ToList()
                    )).ToList()
                )).ToList();
            var paper = new InternalExamDto.InternalDeliveryExam(
                examId, exam.Slug, exam.Title, exam.DescriptionMd, exam.Category,
                exam.Level, exam.DurationMin, exam.ImageUrl, sections);
            return Results.Ok(new ApiResultDto(true, "Success", PaperWideNormalizer.Normalize(paper)));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    private static InternalExamDto.InternalDeliveryQuestion MapQuestion(ExamQuestion question, bool showAnswer)
    {
        var nodes = ExamDeliveryLayout.FlowKeys(question.OrderCorrects)
            .Select(key => new InternalExamDto.InternalFlowChartNode(key, key.Replace("-", " ").Trim())).ToList();
        return new InternalExamDto.InternalDeliveryQuestion(
            question.Idx, question.Type, question.Skill, question.Difficulty, question.PromptMd,
            showAnswer ? question.ExplanationMd : null, question.ImageUrl,
            question.Options.Where(o => o.QuestionId == question.Id).OrderBy(o => o.Idx)
                .Select(o => new InternalExamDto.InternalDeliveryOption(
                    o.Id, o.Idx, o.ContentMd, showAnswer ? o.IsCorrect : null, o.ImageUrl, o.AltText)).ToList(),
            nodes.Count > 0 ? nodes : null,
            showAnswer ? question.BlankAcceptTexts : null,
            showAnswer ? question.BlankAcceptRegex : null,
            showAnswer ? question.MatchPairs : null,
            showAnswer ? question.OrderCorrects : null,
            showAnswer ? question.ShortAnswerAcceptTexts : null,
            showAnswer ? question.ShortAnswerAcceptRegex : null,
            question.GroupId, showAnswer ? question.ModelAnswers : null, question.WordList);
    }
}
