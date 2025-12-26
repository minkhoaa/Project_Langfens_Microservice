using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.FlashCard;
using Shared.PublicContracts.Events;
using vocabulary_service.Application.Helper;
using vocabulary_service.Contracts.User;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Infrastructure.Persistence;

namespace vocabulary_service.Features.User;

public interface IUserService
{
    Task<IResult> SubscribeDecks(Guid deckId, Guid userId, CancellationToken token);
    Task<IResult> GetSubscribedDeck(Guid userId, CancellationToken token);
    Task<IResult> GetUserDeck(Guid userId, CancellationToken token);
    
    Task<IResult> GetDueFlashcard(Guid userId, CancellationToken token, int limit = 20);

    Task<IResult> ReviewFlashcard(Guid userId, Guid cardId, ReviewRequest request, CancellationToken token);
    Task<IResult> GetFlashcardProgress(Guid userId, CancellationToken token);
}

public class UserService(VocabularyDbContext context, IPublishEndpoint publishEndpoint) : IUserService
{
    
    public async Task<IResult> SubscribeDecks(Guid deckId, Guid userId, CancellationToken token)
    {
        var exists = await context.Decks.AsNoTracking().Where(a => a.Id == deckId)
            .Select(x => new { x.Id, x.Title, x.DescriptionMd }).FirstOrDefaultAsync(token);
        if (exists == null) return Results.NotFound();
        var sub = await context.UserDecks.FirstOrDefaultAsync(x => x.UserId == userId && x.DeckId == deckId, token);
        if (sub is null)
        {
            sub = new UserDeck
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                DeckId = deckId,
                Status = "ACTIVE",
                SubscribeAt = DateTime.UtcNow
            };
            context.UserDecks.Add(sub);
        }
        else if (sub.Status != "ACTIVE")
        {
            sub.Status = "ACTIVE";
        }
        await context.SaveChangesAsync(token);
        return Results.Ok(new SubscribeResponse(sub.Id, sub.DeckId, exists.Title, sub.Status));
    }

    public async Task<IResult> GetSubscribedDeck(Guid userId, CancellationToken token)
    {
        try
        {
            var subscribedDeck = await context.UserDecks.AsNoTracking().Where(x => x.UserId == userId)
                .Include(x=>x.Deck)
                .Select(x => new 
                {
                    SubscriptionId = x.Id,
                    deckId = x.DeckId, 
                    title = x.Deck.Title,
                    x.Status,
                    x.SubscribeAt
                    
                }).ToListAsync(token);
            return Results.Ok(new ApiResultDto(true, "Success", subscribedDeck));
        }
        catch (Exception e)
        {
            return Results.BadRequest(e.Message);
        }
    }

    public async Task<IResult> GetUserDeck(Guid userId, CancellationToken token)
    {
        try
        {
            var userDecks = await context.Decks.AsNoTracking()
                .Where(x => x.UserId == userId)
                .Select(x => new
                {
                    x.Id,
                    x.UserId,
                    x.Title,
                    x.Slug,
                    x.DescriptionMd,
                    x.Status,
                    x.Category,
                    x.CreatedAt,
                    x.UpdatedAt,
                }).ToListAsync(token);
            return Results.Ok(new ApiResultDto(true, "Success", userDecks));
        }
        catch (Exception e)
        {
            return Results.BadRequest(e.Message);
        }
    }


    public async Task<IResult> GetDueFlashcard(Guid userId, CancellationToken token, int limit = 20)
    {
        limit = Math.Clamp(limit, 1, 20);
        var today = DateTime.UtcNow.Date;
        var deckIds = await context.UserDecks.AsNoTracking()
            .Where(x => x.UserId == userId && x.Status == UserDeckStatus.Active)
            .Select(x => x.Id)
            .ToListAsync(token);
        if (deckIds.Count == 0)
            return Results.Ok(Array.Empty<DueCardDto>());
        
        var deckSlugs = await context.Decks.AsNoTracking()
            .Where(d => deckIds.Contains(d.Id))
            .Select(d => new { d.Id, d.Slug })
            .ToDictionaryAsync(a => a.Id, a => a.Slug, token);
        var due = await context.UserCardReviews.AsNoTracking()
            .Join(context.Cards.AsNoTracking(),
                s => s.CardId,
                c => c.Id,
                (s, c) => new { s, c }
            )
            .Where(x => deckIds.Contains(x.c.DeckId) && x.s.UserId == userId && x.s.DueAt <= today)
            .OrderBy(x => x.s.DueAt)
            .ThenBy(x=>x.c.Idx)
            .Take(limit)
            .Select(x => new DueCardDto(
                x.c.Id,
                x.c.DeckId,
                deckSlugs[x.c.DeckId],
                x.c.Idx,
                x.c.FrontMd,
                x.c.BackMd,
                x.c.HintMd,
                x.s.DueAt
            ))
            .ToListAsync(token);
        return Results.Ok(new ApiResultDto(true, "List of due flashcard", due));
    }

    public async Task<IResult> ReviewFlashcard(Guid userId, Guid cardId, ReviewRequest request, CancellationToken token)
    {
        var now = DateTime.UtcNow;
        var grade = Math.Clamp(request.Grade, 0, 5);
        var card = await context.Cards.AsNoTracking().Where(c => c.Id == cardId)
            .Select(c => new { c.Id, c.DeckId })
            .FirstOrDefaultAsync(token);
        if (card is null) return Results.NotFound();
        var active = await context.UserDecks.AsNoTracking()
            .AnyAsync(x => x.UserId == userId && x.DeckId == card.DeckId && x.Status == "ACTIVE", token);
        if (!active) return Results.StatusCode(403);
        var st = await context.UserCardReviews.FirstOrDefaultAsync(x => x.UserId == userId && x.CardId == cardId, token);
        if (st is null)
        {
            st = new UserCardReview()
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                CardId = cardId,
                Repetition = 0,
                EaseFactor = 2.5,
                IntervalDays = 0,
                DueAt = now.Date,
                LastReviewedAt = null,
                TotalReviews = 0
            };
            context.UserCardReviews.Add(st);
        }

        var (rep, ef, interval, nextDue) = Sm2Scheduler.Apply(st.Repetition, st.EaseFactor, st.IntervalDays , grade, now);
        st.Repetition = rep;
        st.EaseFactor = ef;
        st.IntervalDays = interval;
        st.LastReviewedAt = now;
        st.TotalReviews++;
        st.DueAt = nextDue;
        context.ReviewLogs.Add(new ReviewLog
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = cardId,
            Grade = grade,
            ReviewedAt = now,
            EaseFactor = ef,
            IntervalDays = interval,
            Repetition = rep
        });
        await context.SaveChangesAsync(token);
        
        // Publish gamification event
        var isCorrect = grade >= 3; // SM-2: grade >= 3 means correct recall
        await publishEndpoint.Publish(new CardReviewedEvent(
            userId,
            cardId,
            grade,
            isCorrect
        ), token);
        
        return Results.Ok(new ReviewResponse(cardId, st.Repetition, st.EaseFactor, st.IntervalDays, st.DueAt));
    }

    public async Task<IResult> GetFlashcardProgress(Guid userId, CancellationToken token)
    {
        var today = DateTime.UtcNow.Date;
        var deckIds = await context.UserDecks.AsNoTracking()
            .Where(x => x.UserId == userId && x.Status == UserDeckStatus.Active)
            .Select(x => x.DeckId).Distinct().ToListAsync(token);
        if (deckIds.Count == 0) 
            return Results.Ok(new MyFlashProgressDto([]));
        var infos = await context.Decks.AsNoTracking()
            .Where(d => deckIds.Contains(d.Id))
            .Select(d => new { d.Id, d.Slug, d.Title })
            .ToListAsync(token);
        
        var totals = await context.Cards.AsNoTracking()
            .Where(c => deckIds.Contains(c.DeckId))
            .GroupBy(c => c.DeckId)
            .Select(g => new { DeckId = g.Key, Total = g.Count() })
            .ToListAsync(token);
        
        var states = await context.UserCardReviews.AsNoTracking()
            .Join(context.Cards.AsNoTracking(), s => s.CardId, c => c.Id, (s, c) => new { s, c })
            .Where(x => deckIds.Contains(x.c.DeckId) && x.s.UserId == userId)
            .ToListAsync(token);
        
        var totalMap = totals.ToDictionary(x => x.DeckId, x => x.Total);
        var reviewedMap = states.GroupBy(x => x.c.DeckId).ToDictionary(g => g.Key, g => g.Count());
        var dueMap = states.Where(x => x.s.DueAt <= today).GroupBy(x => x.c.DeckId).ToDictionary(g => g.Key, g => g.Count());
        var avgEfMap = states.GroupBy(x => x.c.DeckId).ToDictionary(g => g.Key, g => g.Average(x => x.s.EaseFactor));
        var items = infos.Select(i =>
            {
                totalMap.TryGetValue(i.Id, out var total);
                reviewedMap.TryGetValue(i.Id, out var reviewed);
                dueMap.TryGetValue(i.Id, out var due);
                avgEfMap.TryGetValue(i.Id, out var avgEf);
                return new DeckProgressItem(i.Id, i.Slug, i.Title, total, reviewed, due, Math.Round(avgEf, 2));
            })
            .OrderBy(x => x.Title)
            .ToList();
        return Results.Ok(new MyFlashProgressDto(items));
    }
}