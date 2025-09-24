using exam_service.Domains.Enums;

namespace exam_service.Contracts.Exams;

public class DtoAdmin
{
    public record AdminExamCreate(string Slug, string Title, string? DescriptionMd, string Category , string Level, int DurationMin);
    public record AdminExamUpdate(string Title, string? DescriptionMd, string Category, string Level, int DurationMin, string Status);
    public record AdminSectionUpsert(int ExamId, int? Idx, string Title, string? InstructionsMd);
    public record AdminSectionUpdate(int ExamId, int? Idx, string Title, string? InstructionsMd);

    public record AdminQuestionUpsert(int SectionId, int? Idx, string Type, string Skill, int Difficulty, string? PromptMd, string? ExplanationMd);
    public record AdminQuestionUpdate(int SectionId, int? Idx, string Type, string Skill, int Difficulty, string? PromptMd, string? ExplanationMd);

    
    public record AdminOptionUpsert(int QuestionId, int? Idx, string ContentMd, bool IsCorrect);
    public record AdminOptionUpdate(int QuestionId, int? Idx, string ContentMd, bool IsCorrect);
}