using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using exam_service.Domains.Entities;

namespace exam_service.Data.Entities;

public class ExamQuestion
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    public int SectionId { get; set; }
    public ExamSection Section { get; set; } = default!;

    public int Idx { get; set; }

    // ví dụ: MULTIPLE_CHOICE_SINGLE, TRUE_FALSE_NOT_GIVEN...
    [Required] public string Type { get; set; } = default!;

    // READING/LISTENING/WRITING/SPEAKING
    [Required] public string Skill { get; set; } = default!;

    public int Difficulty { get; set; } = 1;

    [Required] public string? PromptMd { get; set; } = default!;

    public string? ExplanationMd { get; set; }

    public List<ExamOption> Options { get; set; } = new();
}