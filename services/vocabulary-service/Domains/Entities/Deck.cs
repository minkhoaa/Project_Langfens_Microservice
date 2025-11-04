using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Npgsql.EntityFrameworkCore.PostgreSQL.Query.Expressions.Internal;
using Shared.ExamDto.Contracts.FlashCard;

namespace vocabulary_service.Domains.Entities;
[Table("deck")]
public class Deck
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }
    [Required, MaxLength(255)] public string Slug { get; set; } = null!; 
    [Required] public Guid UserId { get; set; }
    [Required] public string Title { get; set; } = null!;
    public string? DescriptionMd { get; set; } 
    [MaxLength(100)] public string? Category { get; set; } 
    [MaxLength(20)] public string Status { get; set; } = FlashCardStatus.Draft;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public ICollection<Card> Cards { get; set; } = [];
    public ICollection<UserDeck> UserDecks { get; set; } = [];
}
