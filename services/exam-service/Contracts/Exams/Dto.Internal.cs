namespace exam_service.Contracts.Exams;

using System.Collections.Generic;

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
        IReadOnlyList<InternalDeliverySection> Sections);

    public record InternalDeliverySection(
        int Idx,
        string Title,
        string? InstructionsMd,
        IReadOnlyList<InternalDeliveryQuestion> Questions);

    public record InternalDeliveryQuestion(
        int Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        IReadOnlyList<InternalDeliveryOption> Options,
        IReadOnlyDictionary<string, string[]?>? BlankAcceptTexts,
        IReadOnlyDictionary<string, string[]?>? BlankAcceptRegex,
        IReadOnlyDictionary<string, string[]?>? MatchPairs,
        IReadOnlyList<string>? OrderCorrects,
        IReadOnlyList<string>? ShortAnswerAcceptTexts,
        IReadOnlyList<string>? ShortAnswerAcceptRegex);

    public record InternalDeliveryOption(Guid Id, int Idx, string ContentMd, bool? IsCorrect);

    public static class SnapshotSanitizer
    {
        public static InternalDeliveryExam Sanitize(InternalDeliveryExam exam) => exam with
        {
            Sections = exam.Sections.Select(x => x with
            {
                Questions = x.Questions.Select(a => a with
                {
                    Options = a.Options.Select(q => q with { IsCorrect = false }).ToList()
                }).ToList()
            }).ToList()
        };
    }
}
