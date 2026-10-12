using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.Security.Roles;
using exam_service.Application.Common;
namespace exam_service.Features.Exams.InternalEndpoint;

public interface IInternalExamService
{
    public Task<IResult> GetByExamIdAsync(Guid examId, CancellationToken token, bool showAnswer, ClaimsPrincipal user);
}

public class InternalExamService : IInternalExamService
{
    private readonly ExamDbContext _context;
    public InternalExamService(ExamDbContext context) => _context = context;

    public async Task<IResult> GetByExamIdAsync(
        Guid examId,
        CancellationToken token,
        bool showAnswer,
        ClaimsPrincipal user)
    {
        try
        {
            // Defense in depth: the endpoint already requires authentication.
            // Compute caller authority once; downstream visibility checks reference this flag.
            var isAdmin = user?.IsInRole(Roles.Admin) == true;

            var exam = await _context.Exams.AsNoTracking()
                .Include(x => x.Sections)
                .ThenInclude(s => s.Questions)
                .ThenInclude(q => q.Options)
                .Include(x => x.Sections)
                .ThenInclude(s => s.QuestionGroups)
                .ThenInclude(g => g.Questions)
                .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(x => x.Id == examId, token);

            // Draft shielding: non-admin callers cannot distinguish "missing" from "draft".
            // Both Draft and Archived states return 404 for non-admins; Published is open.
            if (exam == null)
                return Results.NotFound(new ApiResultDto(false, "Not found", null!));

            if (!isAdmin && !string.Equals(exam.Status, ExamStatus.Published, StringComparison.Ordinal))
            {
                return Results.NotFound(new ApiResultDto(false, "Not found", null!));
            }

            // Answer-field and explanation suppression: only admins receive the answer
            // key material and explanations on delivery. Non-admin callers always get nulls
            // regardless of the `?showAnswers=true` query parameter, so no key material or
            // solution explanations leak to students during exam delivery.
            var effectiveShowAnswer = showAnswer && isAdmin;

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
                            var flowChartNodes = BuildFlowChartNodes(question.OrderCorrects, effectiveShowAnswer);
                            var nodesOrNull = flowChartNodes.Count > 0 ? flowChartNodes : null;
                            return new InternalExamDto.InternalDeliveryQuestion(
                                question.Idx,
                                question.Type,
                                question.Skill,
                                question.Difficulty,
                                question.PromptMd,
                                effectiveShowAnswer ? question.ExplanationMd : null,
                                question.ImageUrl,
                                question.Options.Where(d => d.QuestionId == question.Id)
                                    .OrderBy(d => d.Idx)
                                    .Select(option => new InternalExamDto.InternalDeliveryOption(
                                        option.Id,
                                        option.Idx,
                                        option.ContentMd,
                                        effectiveShowAnswer ? option.IsCorrect : null,
                                        option.ImageUrl,
                                        option.AltText
                                    )).ToList(),
                                nodesOrNull,
                                effectiveShowAnswer ? question.BlankAcceptTexts : null,
                                effectiveShowAnswer ? question.BlankAcceptRegex : null,
                                effectiveShowAnswer ? question.MatchPairs : null,
                                effectiveShowAnswer ? question.OrderCorrects : null,
                                effectiveShowAnswer ? question.ShortAnswerAcceptTexts : null,
                                effectiveShowAnswer ? question.ShortAnswerAcceptRegex : null,
                                question.GroupId,
                                effectiveShowAnswer ? question.ModelAnswers : null,
                                question.WordList
                            );
                        }).ToList(),
                    section.QuestionGroups
                        .OrderBy(g => g.Idx)
                        .Select(group =>
                        {
                            var groupQuestions = (group.Questions != null && group.Questions.Count > 0)
                                ? (IEnumerable<exam_service.Domains.Entities.ExamQuestion>)group.Questions
                                : section.Questions.Where(q => q.Idx >= group.StartIdx && q.Idx <= group.EndIdx);

                            return new InternalExamDto.InternalDeliveryQuestionGroup(
                                group.Id,
                                group.Idx,
                                group.StartIdx,
                                group.EndIdx,
                                group.InstructionMd,
                                groupQuestions
                                    .OrderBy(q => q.Idx)
                                    .Select(q =>
                                    {
                                        var flowChartNodes = BuildFlowChartNodes(q.OrderCorrects, effectiveShowAnswer);
                                        var nodesOrNull = flowChartNodes.Count > 0 ? flowChartNodes : null;
                                        return new InternalExamDto.InternalDeliveryQuestion(
                                            q.Idx, q.Type, q.Skill, q.Difficulty, q.PromptMd,
                                            effectiveShowAnswer ? q.ExplanationMd : null,
                                            q.ImageUrl,
                                            q.Options.OrderBy(o => o.Idx)
                                                .Select(o => new InternalExamDto.InternalDeliveryOption(
                                                    o.Id, o.Idx, o.ContentMd, effectiveShowAnswer ? o.IsCorrect : null,
                                                    o.ImageUrl, o.AltText
                                                )).ToList(),
                                            nodesOrNull,
                                            effectiveShowAnswer ? q.BlankAcceptTexts : null,
                                            effectiveShowAnswer ? q.BlankAcceptRegex : null,
                                            effectiveShowAnswer ? q.MatchPairs : null,
                                            effectiveShowAnswer ? q.OrderCorrects : null,
                                            effectiveShowAnswer ? q.ShortAnswerAcceptTexts : null,
                                            effectiveShowAnswer ? q.ShortAnswerAcceptRegex : null,
                                            q.GroupId,
                                            effectiveShowAnswer ? q.ModelAnswers : null,
                                            q.WordList
                                        );
                                    }).ToList()
                            );
                        }).ToList()
                )).ToList();

            var paper = new InternalExamDto.InternalDeliveryExam(
                examId,
                exam.Slug,
                exam.Title,
                exam.DescriptionMd,
                exam.Category,
                exam.Level,
                exam.DurationMin,
                exam.ImageUrl,  // Thumbnail/cover image URL
                sections);
            return Results.Ok(new ApiResultDto(true, "Success", PaperWideNormalizer.Normalize(paper)));
        }
         catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    private static List<InternalExamDto.InternalFlowChartNode> BuildFlowChartNodes(
        IReadOnlyCollection<string>? orderCorrects,
        bool showAnswers)
    {
        if (orderCorrects is not { Count: > 0 }) return new List<InternalExamDto.InternalFlowChartNode>();

        if (!showAnswers)
        {
            var validCount = orderCorrects.Count(x => !string.IsNullOrWhiteSpace(x));
            return Enumerable.Range(1, validCount)
                .Select(i => new InternalExamDto.InternalFlowChartNode(
                    $"step-{i}",
                    $"Step {i}"
                ))
                .ToList();
        }

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
