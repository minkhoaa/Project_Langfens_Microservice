using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using attempt_service.Domain.Enums;

namespace attempt_service.Domain.Entities;

public class Attempt
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [Required] public Guid UserId { get; set; }
    [Required] public Guid ExamId { get; set; }

    [Required] [Column("status")] public string Status { get; set; } = AttemptStatus.Started;

    [Required] public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public DateTime? SubmittedAt { get; set; }
    public DateTime? GradedAt { get; set; }

    [Required] public int DurationSec { get; set; }

    public decimal? RawScore { get; set; }

    public decimal? ScaledScore { get; set; }

    // snapshot
    public JsonDocument? PaperJson { get; set; }

    [Required] public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    [Required] public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<AttemptAnswer> Answers { get; set; } = new List<AttemptAnswer>();
}
