using System.Text.Json;

namespace attempt_service.Features.Attempt;

/// <summary>
/// FE-facing paper shape. Mirrors <c>attempt_service</c>'s persisted jsonb,
/// which uses <c>sections → questionGroups → questions</c>. Task 19 will
/// refine the projection when the per-endpoint DTOs land; for now we model
/// what is already on disk so AttemptFlow can iterate and grade.
/// </summary>
public sealed record PaperJson(
    Guid Id,
    string Slug,
    string Title,
    string? DescriptionMd,
    string Category,
    string Level,
    int DurationMin,
    string? ImageUrl,
    string? Skill,
    IReadOnlyList<PaperSection> Sections);

public sealed record PaperSection(
    Guid Id,
    int Idx,
    string Title,
    string? Skill,
    string? InstructionsMd,
    string? PassageMd,
    string? AudioUrl,
    string? TranscriptMd,
    IReadOnlyList<PaperQuestionGroup> QuestionGroups,
    IReadOnlyList<PaperQuestion> Questions);

public sealed record PaperQuestionGroup(
    Guid Id,
    int Idx,
    string? InstructionMd,
    int StartIdx,
    int EndIdx,
    IReadOnlyList<PaperQuestion> Questions);

public sealed record PaperQuestion(
    Guid Id,
    int Idx,
    string Type,
    string Skill,
    Guid SectionId,
    JsonElement Payload,
    JsonElement? CorrectAnswer,
    JsonElement? Rubric);
