using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;

namespace attempt_service.Domain.Entities;

public class AttemptAnswer
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required] public Guid AttemptId { get; set; }
    public Attempt Attempt { get; set; } = null!;

    [Required] public Guid SectionId { get; set; }
    [Required] public Guid QuestionId { get; set; }

    /// <summary>Per-type SSOT-correct answer shape.</summary>
    [Required]
    [Column(TypeName = "jsonb")]
    public JsonDocument AnswerJson { get; set; } = null!;

    public decimal? AwardedPoints { get; set; }
    public bool? IsCorrect { get; set; }

    [Column(TypeName = "jsonb")]
    public JsonDocument? RagFeedbackJson { get; set; }

    [Required] public DateTime AnsweredAt { get; set; } = DateTime.UtcNow;
}