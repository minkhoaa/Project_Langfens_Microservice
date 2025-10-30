using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.FlashCard;
using vocabulary_service.Application.Helper;
using vocabulary_service.Contracts;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Infrastructure.Persistence;

namespace vocabulary_service.Features.User;

public interface IUserService
{
    Task<IResult> CreateDeck(DeckDto dto, CancellationToken token);
}

public class UserService(VocabularyDbContext context) : IUserService
{
    
    public async Task<IResult> CreateDeck(DeckDto dto, CancellationToken token)
    {
        var slug = await SlugHelper.MakeUniqueSlugAsync(context, dto.Slug, token);
        var deck = new Deck
        {
            Slug = slug,
            Category = dto.Category,
            DescriptionMd = dto.DescriptionMd,
            Status = dto.Status ?? FlashCardStatus.Draft,
            Title = dto.Title,
            UpdatedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
        context.Decks.Add(deck);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Created successfully", new { deck.Id, deck.Slug, deck.CreatedAt }));
    }
}