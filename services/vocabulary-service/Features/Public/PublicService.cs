using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.FlashCard;
using vocabulary_service.Contracts;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Infrastructure.Persistence;

namespace vocabulary_service.Features.Public;

public interface IPublicService
{
    Task<IResult> GetAllPublished(string? status, string? category, CancellationToken token, int page, int? pageSize = 5);
    Task<IResult> GetBySlug(string slug, CancellationToken token);
    Task<IResult> GetCardsBySlug(string slug, CancellationToken token);


}
public class PublicService(VocabularyDbContext context) : IPublicService
{
    public async Task<IResult> GetAllPublished(string? status, string? category, CancellationToken token, int page, int? pageSize)
    {
        int size = pageSize ?? 20;
        IQueryable<Deck> q = context.Decks.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(status)) q = q.Where(x => x.Status == status);
        if (!string.IsNullOrWhiteSpace(category)) q = q.Where(x => x.Category == category);
        
        var items = await q.OrderBy(x => x.Title)
            .Skip((page - 1) * size)
            .Take(size)
            .Select(x => new DeckListItemDto(x.Id, x.Slug, x.Title, x.Category, x.Status))
            .ToListAsync(token);
        return Results.Ok(items);
    }

    public async Task<IResult> GetBySlug(string slug, CancellationToken token)
    {
        var deck = await context.Decks.AsNoTracking()
            .Where(d => d.Slug == slug)
            .Select(d => new DeckDetailDto(d.Id, d.Slug, d.Title, d.DescriptionMd, d.Category, d.Status))
            .FirstOrDefaultAsync(token);
        return deck is null ? Results.NotFound() : Results.Ok(deck);
    }

    public async Task<IResult> GetCardsBySlug(string slug, CancellationToken token)
    {
        var deckId = await context.Decks.AsNoTracking()
            .Where(d => d.Slug == slug)
            .Select(d => d.Id)
            .FirstOrDefaultAsync(token);
        if (deckId == Guid.Empty) return Results.NotFound("Not found deck slug");
        var cards = await context.Cards.AsNoTracking()
            .Where(c => c.DeckId == deckId)
            .OrderBy(c => c.Idx)
            .Select(c => new CardItemDto(c.Id, c.Idx, c.FrontMd, c.BackMd, c.HintMd))
            .ToListAsync(token);
        return Results.Ok(cards);
    }
}