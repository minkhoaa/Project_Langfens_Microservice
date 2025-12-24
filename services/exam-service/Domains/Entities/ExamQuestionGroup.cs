using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

/// <summary>
/// Groups questions by their instruction headers for IELTS exam display.
/// Each group has its own instruction rendered with its questions.
/// </summary>
public class ExamQuestionGroup
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid SectionId { get; set; }
    public ExamSection Section { get; set; } = null!;

    /// <summary>
    /// Order of this group within the section (1, 2, 3...)
    /// </summary>
    public int Idx { get; set; }

    /// <summary>
    /// First question index in this group (e.g., 1 for Q1-7)
    /// </summary>
    public int StartIdx { get; set; }

    /// <summary>
    /// Last question index in this group (e.g., 7 for Q1-7)
    /// </summary>
    public int EndIdx { get; set; }

    /// <summary>
    /// Markdown instruction for this question group.
    /// Example: "## Questions 1-7\nComplete the notes below..."
    /// </summary>
    [Required]
    public string InstructionMd { get; set; } = string.Empty;

    public List<ExamQuestion> Questions { get; set; } = new();
}
