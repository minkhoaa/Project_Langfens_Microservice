namespace ExamService.Domains.Entities;

public sealed class ExamSection
{
    public Guid Id { get; set; }

    public Guid ExamId { get; set; }

    public int Idx { get; set; }

    public string Title { get; set; } = "";

    public string? InstructionsMd { get; set; }

    public string? PassageMd { get; set; }

    public string? AudioUrl { get; set; }

    public string? TranscriptMd { get; set; }

    public List<ExamQuestionGroup> QuestionGroups { get; set; } = new();
    public List<ExamQuestion> Questions { get; set; } = new();
    public Exam Exam { get; set; } = null!;
}