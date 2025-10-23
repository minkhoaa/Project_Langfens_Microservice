using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace vocabulary_service.Domains.Entities;
[Table("card")]
public class Card
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }
    public Guid DeckId { get; set; }
    public int Idx { get; set; } 
    [Required] public string FrontMd { get; set; } = null!;
    [Required] public string BackMd { get; set; } = null!;
    public string? HintMd { get; set; }
    public Deck Deck { get; set; } = null!;
    public ICollection<ReviewLog> ReviewLogs { get; set; } = [];
    public ICollection<UserCardReview> UserCardReviews { get; set; } = [];

}