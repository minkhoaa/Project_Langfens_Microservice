using System.Text.Json;

namespace ExamService.Features.Exams.Dtos;

// FE-facing paper shape. The admin variant exposes `CorrectAnswer` + `Rubric`;
// the public/learner variant (Task 11) will omit them. See spec §3.1.

public sealed record PaperJson(
    Guid Id,
    string Slug,
    string Title,
    string? DescriptionMd,
    string Category,
    string Level,
    int DurationMin,
    string? ImageUrl,
    IReadOnlyList<PaperSection> Sections);

public sealed record PaperSection(
    Guid Id,
    int Idx,
    string Title,
    string? InstructionsMd,
    string? PassageMd,
    string? AudioUrl,
    string? TranscriptMd,
    IReadOnlyList<PaperQuestion> Questions);

public sealed record PaperQuestion(
    Guid Id,
    int Idx,
    string Type,
    string Skill,
    JsonElement Payload,
    JsonElement? CorrectAnswer,
    JsonElement? Rubric);
