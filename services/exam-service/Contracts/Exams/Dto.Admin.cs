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
        int DurationMin,
        string? ImageUrl
        );

    public record AdminExamUpdate(
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        string? ImageUrl,
        string Status);

    public record AdminSectionUpsert(
        Guid ExamId,
        int? Idx,
        string Title,
        string? InstructionsMd,
        string? PassageMd,
        string? AudioUrl,
        string? TranscriptMd);

    public record AdminSectionUpdate(
        Guid ExamId,
        int? Idx,
        string Title,
        string? InstructionsMd,
        string? PassageMd,
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
        string? ImageUrl = null,
        Dictionary<string, string[]?>? BlankAcceptTexts = null,
        Dictionary<string, string[]?>? BlankAcceptRegex = null,
        Dictionary<string, string[]?>? MatchPairs = null,
        IEnumerable<string>? OrderCorrects = null,
        IEnumerable<string>? ShortAnswerAcceptTexts = null,
        IEnumerable<string>? ShortAnswerAcceptRegex = null);

    public record AdminQuestionUpdate(
        Guid SectionId,
        int? Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        string? ImageUrl = null,
        Dictionary<string, string[]?>? BlankAcceptTexts = null,
        Dictionary<string, string[]?>? BlankAcceptRegex = null,
        Dictionary<string, string[]?>? MatchPairs = null,
        IEnumerable<string>? OrderCorrects = null,
        IEnumerable<string>? ShortAnswerAcceptTexts = null,
        IEnumerable<string>? ShortAnswerAcceptRegex = null);


    public record AdminOptionUpsert(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect, string? ImageUrl = null, string? AltText = null);

    public record AdminOptionUpdate(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect, string? ImageUrl = null, string? AltText = null);
}
