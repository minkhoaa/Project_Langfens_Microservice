using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

public class ExamSection
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid ExamId { get; set; }
    public Exam Exam { get; set; } = null!;

    public int Idx { get; set; } // thứ tự trong đề

    [Required] public string Title { get; set; } = string.Empty!;

    public string? InstructionsMd { get; set; }
    public string? AudioUrl { get; set; }
    public string? TranscriptMd { get; set; }

    public List<ExamQuestion> Questions { get; set; } = new();
}
