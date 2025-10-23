using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace vocabulary_service.Domains.Entities;

public class ReviewLog
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid CardId { get; set; }
    public int Grade { get; set; }
    public DateTime ReviewedAt { get; set; }
    public Card Card { get; set; } = null!;

    public double EaseFactor { get; set; }
    public int IntervalDays { get; set; }
    public int Repetition { get; set; }
}