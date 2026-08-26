namespace ExamService.Domains.Entities;

public sealed class ExamOption
{
    public Guid Id { get; set; }

    public Guid QuestionId { get; set; }

    public int Idx { get; set; }

    public string ContentMd { get; set; } = "";

    /// <summary>
    /// Admin-UI convenience flag. <c>payload.options[].isCorrect</c> is the
    /// source of truth; this column is redundant with the jsonb but kept for
    /// Phase-1.5 cleanup per spec §2.1.
    /// </summary>
    public bool? IsCorrect { get; set; }
    public ExamQuestion Question { get; set; } = null!;
}