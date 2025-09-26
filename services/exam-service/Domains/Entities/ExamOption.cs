using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Data.Entities;

public class ExamOption
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int QuestionId { get; set; }
    public ExamQuestion Question { get; set; } = default!;

    public int Idx { get; set; }

    [Required] public string ContentMd { get; set; } = default!;

    public bool IsCorrect { get; set; }
}