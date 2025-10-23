using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace vocabulary_service.Domains.Entities;

public class UserCardReview
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid CardId { get; set; }

    public int Repetition { get; set; }
    public double EaseFactor { get; set; } = 2.5; 
    public int IntervalDays { get; set; }
    
    public DateTime DueAt { get; set; }
    public DateTime? LastReviewedAt { get; set; }
    public int TotalReviews { get; set; }
    public Card Card { get; set; } = null!;
}