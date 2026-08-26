namespace ExamService.Domains.Entities;

public sealed class ExamQuestionGroup
{
    public Guid Id { get; set; }

    public Guid SectionId { get; set; }

    public int Idx { get; set; }

    public int StartIdx { get; set; }

    public int EndIdx { get; set; }

    public string InstructionMd { get; set; } = "";

    public List<ExamQuestion> Questions { get; set; } = new();
    public ExamSection Section { get; set; } = null!;
}