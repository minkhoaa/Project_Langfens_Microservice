using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace exam_service.Domains.Entities;

public class ExamOption
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    public Guid QuestionId { get; set; }
    public ExamQuestion Question { get; set; } = default!;

    public int Idx { get; set; }

    [Required] public string ContentMd { get; set; } = default!;

    public bool IsCorrect { get; set; }

    /// <summary>
    /// Optional image URL for image-based MCQ options (MULTIPLE_CHOICE_SINGLE_IMAGE).
    /// When set, candidates see the image instead of (or alongside) the text content.
    /// </summary>
    public string? ImageUrl { get; set; }

    /// <summary>
    /// Alt text for accessibility (screen readers) when <see cref="ImageUrl"/> is set.
    /// </summary>
    public string? AltText { get; set; }
}