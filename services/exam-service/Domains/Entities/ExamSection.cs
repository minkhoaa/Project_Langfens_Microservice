using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using exam_service.Domains.Entities;

namespace exam_service.Data.Entities;


public class ExamSection
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int ExamId { get; set; }
    public Exam Exam { get; set; } = default!;

    public int Idx { get; set; } // thứ tự trong đề

    [Required]
    public string Title { get; set; } = default!;

    public string? InstructionsMd { get; set; }

    public List<ExamQuestion> Questions { get; set; } = new();
}
