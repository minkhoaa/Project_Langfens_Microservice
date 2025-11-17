using System.Collections.Generic;

namespace exam_service.Contracts.Exams;

public class DtoAdmin
{
    public record AdminExamCreate(
        string Title,
        string Slug,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin);

    public record AdminExamUpdate(
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        string Status);

    public record AdminSectionUpsert(
        Guid ExamId,
        int? Idx,
        string Title,
        string? InstructionsMd,
        string? AudioUrl,
        string? TranscriptMd);

    public record AdminSectionUpdate(
        Guid ExamId,
        int? Idx,
        string Title,
        string? InstructionsMd,
        string? AudioUrl,
        string? TranscriptMd);

    public record AdminQuestionUpsert(
        Guid SectionId,
        int? Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        Dictionary<string, string[]?>? BlankAcceptTexts,
        Dictionary<string, string[]?>? BlankAcceptRegex,
        Dictionary<string, string[]?>? MatchPairs,
        IEnumerable<string>? OrderCorrects,
        IEnumerable<string>? ShortAnswerAcceptTexts,
        IEnumerable<string>? ShortAnswerAcceptRegex);

    public record AdminQuestionUpdate(
        Guid SectionId,
        int? Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        Dictionary<string, string[]?>? BlankAcceptTexts,
        Dictionary<string, string[]?>? BlankAcceptRegex,
        Dictionary<string, string[]?>? MatchPairs,
        IEnumerable<string>? OrderCorrects,
        IEnumerable<string>? ShortAnswerAcceptTexts,
        IEnumerable<string>? ShortAnswerAcceptRegex);


    public record AdminOptionUpsert(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect);

    public record AdminOptionUpdate(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect);
}
