using Shared.ExamDto.Contracts.Deck;
using Shared.ExamDto.Contracts.FlashCard;

namespace vocabulary_service.Contracts;

public class DeckDto
{
    public string Slug { get; set; } = null!; 
    public string Title { get; set; } = null!;
    public string? DescriptionMd { get; set; }
    public string? Category { get; set; } = DeckCategory.Ielts;
    public string? Status { get; set; } = FlashCardStatus.Draft;
    public DateTime CreatedAt { get; set; } 
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
 
}
