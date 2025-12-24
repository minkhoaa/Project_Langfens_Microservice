namespace exam_service.Contracts.Exams;

public class Dto_Public
{
    public record PublicExamRecord(
        Guid Id,
        string Slug,
        string Title,
        string Category,
        string Level,
        int DurationMin,
        DateTime? updateAt,
        string ImageUrl
        );

    public record PubLicExamDetailRecord(
        Guid Id,
        string Slug,
        string Title,
        string? DescriptionMd,
        string Category,
        string Level,
        int DurationMin,
        string ImageUrl,
        IReadOnlyList<PublicSectionRecord> sections);

    public record PublicSectionRecord(
        int idx,
        string Title,
        string? InstructionMd,
        string? PassageMd,
        string? AudioUrl,
        string? TranscriptMd,
        List<PublicQuestionRecord> Questions,
        List<PublicQuestionGroupRecord>? QuestionGroups);

    public record PublicQuestionGroupRecord(
        Guid Id,
        int Idx,
        int StartIdx,
        int EndIdx,
        string InstructionMd,
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

