using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Shared.ExamDto.Contracts.FlashCard;

namespace vocabulary_service.Domains.Entities;

public class UserDeck
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; } 
    [Required]
    public Guid UserId { get; set; }
    [Required]
    public Guid DeckId { get; set; }

    [MaxLength(20)] public string Status { get; set; } = UserDeckStatus.Active;
    public DateTime SubscribeAt { get; set; }
    public Deck Deck { get; set; } = null!;
}