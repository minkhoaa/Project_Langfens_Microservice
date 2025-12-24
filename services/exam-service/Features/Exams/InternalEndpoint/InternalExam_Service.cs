using System;
using System.Collections.Generic;
using System.Linq;
using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace exam_service.Features.Exams.InternalEndpoint;

public interface IInternalExamService
{
    public Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token, bool showAnswer);
}

public class InternalExamService : IInternalExamService
{
    private readonly ExamDbContext _context;
    public InternalExamService(ExamDbContext context) => _context = context;

    public async Task<IResult> GetByExamIdAsync(
        Guid examId,
        CancellationToken token,
        bool showAnswer)
    {
        try
        {
            var exam = await _context.Exams.AsNoTracking()
                .Include(x => x.Sections)
                .ThenInclude(s => s.Questions)
                .ThenInclude(q => q.Options)
                .Include(x => x.Sections)
                .ThenInclude(s => s.QuestionGroups)
                .ThenInclude(g => g.Questions)
                .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(x => x.Id == examId, token);

            if (exam == null)
                return Results.NotFound(new ApiResultDto(false, "Not found", null!));

            var sections = exam.Sections
                .Where(s => s.ExamId == exam.Id)
                .OrderBy(s => s.Idx)
                .Select(section => new InternalExamDto.InternalDeliverySection(
                    section.Idx,
                    section.Title,
                    section.InstructionsMd,
                    section.PassageMd,
                    section.AudioUrl,
                    section.TranscriptMd,
                    section.Questions
                        .Where(a => a.SectionId == section.Id)
                        .OrderBy(a => a.Idx)
                        .Select(question =>
                        {
                            var flowChartNodes = BuildFlowChartNodes(question.OrderCorrects);
                            var nodesOrNull = flowChartNodes.Count > 0 ? flowChartNodes : null;
                            return new InternalExamDto.InternalDeliveryQuestion(
                                question.Idx,
                                question.Type,
                                question.Skill,
                                question.Difficulty,
                                question.PromptMd,
                                question.ExplanationMd,
                                question.Options.Where(d => d.QuestionId == question.Id)
                                    .OrderBy(d => d.Idx)
                                    .Select(option => new InternalExamDto.InternalDeliveryOption(
                                        option.Id,
                                        option.Idx,
                                        option.ContentMd,
                                        showAnswer ? option.IsCorrect : null
                                    )).ToList(),
                                nodesOrNull,
                                showAnswer ? question.BlankAcceptTexts : null,
                                showAnswer ? question.BlankAcceptRegex : null,
                                showAnswer ? question.MatchPairs : null,
                                showAnswer ? question.OrderCorrects : null,
                                showAnswer ? question.ShortAnswerAcceptTexts : null,
                                showAnswer ? question.ShortAnswerAcceptRegex : null
                            );
                        }).ToList(),
                    section.QuestionGroups
                        .OrderBy(g => g.Idx)
                        .Select(group => new InternalExamDto.InternalDeliveryQuestionGroup(
                            group.Id,
                            group.Idx,
                            group.StartIdx,
                            group.EndIdx,
                            group.InstructionMd,
                            group.Questions
                                .OrderBy(q => q.Idx)
                                .Select(q =>
                                {
                                    var flowChartNodes = BuildFlowChartNodes(q.OrderCorrects);
                                    var nodesOrNull = flowChartNodes.Count > 0 ? flowChartNodes : null;
                                    return new InternalExamDto.InternalDeliveryQuestion(
                                        q.Idx, q.Type, q.Skill, q.Difficulty, q.PromptMd, q.ExplanationMd,
                                        q.Options.OrderBy(o => o.Idx)
                                            .Select(o => new InternalExamDto.InternalDeliveryOption(
                                                o.Id, o.Idx, o.ContentMd, showAnswer ? o.IsCorrect : null
                                            )).ToList(),
                                        nodesOrNull,
                                        showAnswer ? q.BlankAcceptTexts : null,
                                        showAnswer ? q.BlankAcceptRegex : null,
                                        showAnswer ? q.MatchPairs : null,
                                        showAnswer ? q.OrderCorrects : null,
                                        showAnswer ? q.ShortAnswerAcceptTexts : null,
                                        showAnswer ? q.ShortAnswerAcceptRegex : null
                                    );
                                }).ToList()
                        )).ToList()
                )).ToList();

            var paper = new InternalExamDto.InternalDeliveryExam(
                examId,
                exam.Slug,
                exam.Slug,
                exam.DescriptionMd,
                exam.Category,
                exam.Level,
                exam.DurationMin,
                exam.ImageUrl,  // Thumbnail/cover image URL
                sections);

            return paper != null
                ? Results.Ok(new ApiResultDto(true, "Success", paper))
                : Results.NotFound(new ApiResultDto(false, "Not found", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    private static List<InternalExamDto.InternalFlowChartNode> BuildFlowChartNodes(IReadOnlyCollection<string>? orderCorrects)
    {
        if (orderCorrects is not { Count: > 0 }) return new List<InternalExamDto.InternalFlowChartNode>();

        var nodes = orderCorrects
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Select(key => new InternalExamDto.InternalFlowChartNode(
                key,
                key.Replace("-", " ").Trim()
            ))
            .ToList();

        return nodes.OrderBy(_ => Guid.NewGuid()).ToList();
    }
}
