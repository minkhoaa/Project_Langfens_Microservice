namespace exam_service.Contracts.Exams;

public class Dto_Public
{
    public record PublicExamRecord(
        int Id,
        string Slug,
        string Title,
        string Category,
        string Level,
        int DurationMin,
        DateTime? updateAt);

    public record PubLicExamDetailRecord(
        int Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        IReadOnlyList<PublicSectionRecord> sections);

    public record PublicSectionRecord(
        int idx,
        string Title,
        string? InstructionMd,
        List<PublicQuestionRecord> Questions);

    public record PublicQuestionRecord(
        int Idx,
        string Type,
        string Skill,
        int Difficulty,
        string? PromptMd,
        IReadOnlyList<PublicOptionRecord> Options);

    public record PublicOptionRecord(int idx, string ContentMd);
}