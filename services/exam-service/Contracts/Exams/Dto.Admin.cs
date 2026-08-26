using System.Collections.Generic;
using System.Text.Json;

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

    /// <summary>
    /// Admin upsert payload for an <c>ExamQuestion</c>. Carries the canonical
    /// SSOT envelope (Phase 4 <c>Payload</c> column) alongside the legacy
    /// nullable columns so dual-write stays in a single SaveChanges round-trip.
    /// </summary>
    public record AdminQuestionUpsert(
        Guid SectionId,
        int? Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        /// <summary>
        /// SSOT discriminated-union envelope { type, payload, correctAnswer, rubric }.
        /// When provided, persisted to <c>ExamQuestion.Payload</c> (jsonb).
        /// Legacy columns below are always populated in parallel.
        /// </summary>
        JsonElement? Payload,
        Dictionary<string, string[]?>? BlankAcceptTexts,
        Dictionary<string, string[]?>? BlankAcceptRegex,
        Dictionary<string, string[]?>? MatchPairs,
        IEnumerable<string>? OrderCorrects,
        IEnumerable<string>? ShortAnswerAcceptTexts,
        IEnumerable<string>? ShortAnswerAcceptRegex);

    /// <summary>
    /// Admin update payload for an <c>ExamQuestion</c>. Same dual-write
    /// contract as <see cref="AdminQuestionUpsert"/>.
    /// </summary>
    public record AdminQuestionUpdate(
        Guid SectionId,
        int? Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        string? ExplanationMd,
        /// <summary>
        /// SSOT discriminated-union envelope. Replaces the persisted
        /// <c>ExamQuestion.Payload</c> column when provided.
        /// </summary>
        JsonElement? Payload,
        Dictionary<string, string[]?>? BlankAcceptTexts,
        Dictionary<string, string[]?>? BlankAcceptRegex,
        Dictionary<string, string[]?>? MatchPairs,
        IEnumerable<string>? OrderCorrects,
        IEnumerable<string>? ShortAnswerAcceptTexts,
        IEnumerable<string>? ShortAnswerAcceptRegex);


    public record AdminOptionUpsert(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect);

    public record AdminOptionUpdate(Guid QuestionId, int? Idx, string ContentMd, bool IsCorrect);
}
