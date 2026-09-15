namespace exam_service.Contracts.Exams;

using System.Collections.Generic;
using System.Linq;

public class InternalExamDto
{
    public record InternalDeliveryExam(
        Guid Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        string? ImageUrl,  // Thumbnail/cover image URL
        IReadOnlyList<InternalDeliverySection> Sections);

    public record InternalDeliverySection(
        int Idx,
        string Title,
        string? InstructionsMd,
        string? PassageMd,
        string? AudioUrl,
        string? TranscriptMd,
        IReadOnlyList<InternalDeliveryQuestion> Questions,
        IReadOnlyList<InternalDeliveryQuestionGroup>? QuestionGroups);

    public record InternalDeliveryQuestionGroup(
        Guid Id,
        int Idx,
        int StartIdx,
        int EndIdx,
        string InstructionMd,
        IReadOnlyList<InternalDeliveryQuestion> Questions);

    public record InternalDeliveryQuestion(
        int Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        string? ImageUrl = null,
        IReadOnlyList<InternalDeliveryOption>? Options = null,
        IReadOnlyList<InternalFlowChartNode>? FlowChartNodes = null,
        IReadOnlyDictionary<string, string[]?>? BlankAcceptTexts = null,
        IReadOnlyDictionary<string, string[]?>? BlankAcceptRegex = null,
        IReadOnlyDictionary<string, string[]?>? MatchPairs = null,
        IReadOnlyList<string>? OrderCorrects = null,
        IReadOnlyList<string>? ShortAnswerAcceptTexts = null,
        IReadOnlyList<string>? ShortAnswerAcceptRegex = null,
        Guid? GroupId = null,
        IReadOnlyList<string>? ModelAnswers = null,
        IReadOnlyList<string>? WordList = null);

    public record InternalDeliveryOption(Guid Id, int Idx, string ContentMd, bool? IsCorrect, string? ImageUrl = null, string? AltText = null);

    public record InternalFlowChartNode(string Key, string Label);

    public static class SnapshotSanitizer
    {
        public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam) => exam with
        {
            Sections = exam.Sections.Select(x => x with
            {
                Questions = x.Questions.Select(a => a with
                {
                    Options = a.Options.Select(q => q with { IsCorrect = false }).ToList()
                }).ToList(),
                QuestionGroups = x.QuestionGroups?.Select(g => g with
                {
                    Questions = g.Questions.Select(a => a with
                    {
                        Options = a.Options.Select(q => q with { IsCorrect = false }).ToList()
                    }).ToList()
                }).ToList()
            }).ToList()
        };
    }
}
