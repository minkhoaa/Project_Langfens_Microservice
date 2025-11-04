using System.Numerics;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Deck;
using Shared.ExamDto.Contracts.FlashCard;
using vocabulary_service.Application.Helper;
using vocabulary_service.Contracts.Admin;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Infrastructure.Persistence;

namespace vocabulary_service.Features.Admin;

public interface IAdminService
{
    Task<IResult> CreateDeck(CreateDeckRequest dto, CancellationToken token);
    Task<IResult> UpdateDeck(UpdateDeckRequest dto, Guid deckId , CancellationToken token);
    Task<IResult> DeleteDeck(Guid deckId , CancellationToken token);
    Task<IResult> MakeDeckPublic(Guid deckId, CancellationToken token);
    
    Task<IResult> CreateCards(Guid deckId, CreateCardRequest request, CancellationToken token);
    Task<IResult> UpdateCards(Guid cardId, UpdateCardRequest request, CancellationToken token);
    Task<IResult> DeleteCards(Guid cardId, CancellationToken token); 

}
public class AdminService(VocabularyDbContext context) : IAdminService
{
    public async Task<IResult> CreateDeck(CreateDeckRequest dto, CancellationToken token)
    {
        var slug = SlugHelper.ToSlug(dto.Slug);
        var newDeck = new Deck
        {
            Slug = slug,
            Category = dto.Category,
            DescriptionMd = dto.DescriptionMd,
            Title = dto.Title,
            UserId = dto.UserId,
            Status = DeckStatus.Draft,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        context.Decks.Add(newDeck);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, 
            "Created successfully", new DeckCreatedDto(newDeck.Id, newDeck.Slug)));
    }
    

    public async Task<IResult> UpdateDeck(UpdateDeckRequest dto, Guid deckId, CancellationToken token)
    {
        
        var existed = await context.Decks
            .Where(x => x.Id == deckId)
            .FirstOrDefaultAsync(token);
        if (existed is null)
            return Results.NotFound();
        if (!string.IsNullOrEmpty(dto.Slug)) existed.Slug = dto.Slug;
        if (!string.IsNullOrEmpty(dto.Title)) existed.Title = dto.Title;
        if (!string.IsNullOrEmpty(dto.DescriptionMd)) existed.DescriptionMd = dto.DescriptionMd;
        if (!string.IsNullOrEmpty(dto.Category) && DeckCategory.IsValid(dto.Category) ) existed.Category = dto.Category;
        if (!string.IsNullOrEmpty(dto.Status) && DeckStatus.IsValid(dto.Status) ) existed.Status = dto.Status;
        try
        {
            existed.UpdatedAt = DateTime.UtcNow;
            context.Update(existed);
            await context.SaveChangesAsync(token);
            return Results.Ok(new ApiResultDto(true, "Updated successfully", existed));
        }
        catch (Exception e)
        {
            return Results.BadRequest(e.Message); 
        }
        
    }

    public async Task<IResult> DeleteDeck(Guid deckId, CancellationToken token)
    {
        try
        {
            var deletedRow = await context.Decks.Where(x => x.Id == deckId)
                .ExecuteDeleteAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {deletedRow}", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }

    public async Task<IResult> MakeDeckPublic(Guid deckId, CancellationToken token)
    {
        try
        {
            await context.Decks.Where(x => x.Id == deckId)
                .ExecuteUpdateAsync(x => x.SetProperty(a => a.Status, FlashCardStatus.Published), token);
            return Results.NoContent();
        }
        catch (Exception e)
    {
        return Results.BadRequest(e.Message);
    }
}


    public async Task<IResult> CreateCards(Guid deckId, CreateCardRequest request, CancellationToken token)
    {
        var deck = await context.Decks.AsNoTracking()
            .Where(x => x.Id == deckId)
            .FirstOrDefaultAsync(token);
        if (deck is null)
            return Results.NotFound();
        var nextIdx = await context.Cards.AsNoTracking()
            .Where(x => x.DeckId == deckId)
            .Select(x => (int?)x.Idx)
            .MaxAsync(token) + 1 ?? 1;
        var newCard = new Card
        {
            DeckId = deckId,
            FrontMd = request.FrontMd,
            BackMd = request.BackMd,
            Idx = nextIdx,
            HintMd = request.HintMd ?? string.Empty
        };
        context.Cards.Add(newCard);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Created successfully", newCard));
    }

    public async Task<IResult> UpdateCards(Guid cardId, UpdateCardRequest request, CancellationToken token)
    {
        var card = await context.Cards.AsNoTracking()
            .Where(x => x.Id == cardId)
            .FirstOrDefaultAsync(token);
        if (card is null)
            return Results.NotFound();
        if (request.Idx is not null) card.Idx = (int)request.Idx;
        if (!string.IsNullOrEmpty(request.BackMd)) card.BackMd = request.BackMd;
        if (!string.IsNullOrEmpty(request.FrontMd)) card.FrontMd = request.FrontMd;
        if (!string.IsNullOrEmpty(request.HintMd)) card.HintMd = request.HintMd;
        context.Cards.Update(card);
        await context.SaveChangesAsync(token);
        return Results.Ok(new ApiResultDto(true, "Update successfully", 
            new {card.FrontMd, card.BackMd, card.Idx}));

    }

    public async Task<IResult> DeleteCards(Guid cardId, CancellationToken token)
    {
        try
        {
            var affectedRow = await context.Cards.Where(x => x.Id == cardId)
                .ExecuteDeleteAsync(token);
            return Results.Ok(new ApiResultDto(true, $"Deleted {affectedRow} rows", null!));
        }
        catch (Exception e)
        {
            return Results.BadRequest(new ApiResultDto(false, e.Message, null!));
        }
    }
}
