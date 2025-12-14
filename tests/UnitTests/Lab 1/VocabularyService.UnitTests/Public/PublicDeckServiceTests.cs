using Microsoft.AspNetCore.Mvc;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Features.Public;
using Shared.ExamDto.Contracts.Deck;
using Shared.ExamDto.Contracts.FlashCard;
using vocabulary_service.Contracts;
using vocabulary_service.Infrastructure.Persistence;

namespace VocabularyService.UnitTests.Public;

public class PublicDeckServiceTests
{
    [Fact]
    public async Task ListPublished_Should_Filter_By_Status()
    {
        await using var handle = SqliteInMemoryFactory.Create<VocabularyDbContext>();
        var ctx = handle.Context;
        ctx.Decks.AddRange(
            new Deck { Id = Guid.NewGuid(), Slug = "deck-pub", Title = "Deck Pub", Status = DeckStatus.Published, Category = DeckCategory.Ielts, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
            new Deck { Id = Guid.NewGuid(), Slug = "deck-draft", Title = "Deck Draft", Status = DeckStatus.Draft, Category = DeckCategory.Ielts, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow }
        );
        await ctx.SaveChangesAsync();

        var svc = new PublicService(ctx);
        var result = await svc.GetAllPublished(status: DeckStatus.Published, category: null, token: CancellationToken.None, page: 1, pageSize: 10);
        result.Should().BeOfType<OkObjectResult>();
        var ok = result as OkObjectResult;
        var data = ok!.Value as List<DeckListItemDto>;
        data.Should().NotBeNull();
        data!.Any(d => d.Slug == "deck-draft").Should().BeFalse();
    }

    [Fact]
    public async Task GetBySlug_Should_Return_NotFound_When_Missing()
    {
        await using var handle = SqliteInMemoryFactory.Create<VocabularyDbContext>();
        var svc = new PublicService(handle.Context);
        var result = await svc.GetBySlug("missing", CancellationToken.None);

        result.Should().BeOfType<NotFoundObjectResult>();
    }

    [Fact]
    public async Task GetBySlug_Should_Return_Deck_Detail_When_Exists()
    {
        await using var handle = SqliteInMemoryFactory.Create<VocabularyDbContext>();
        var ctx = handle.Context;
        var deck = new Deck
        {
            Id = Guid.NewGuid(),
            Slug = "deck-detail",
            Title = "Deck Detail",
            DescriptionMd = "desc",
            Category = DeckCategory.Ielts,
            Status = DeckStatus.Published,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        ctx.Decks.Add(deck);
        await ctx.SaveChangesAsync();

        var svc = new PublicService(ctx);
        var result = await svc.GetBySlug("deck-detail", CancellationToken.None);

        result.Should().BeOfType<OkObjectResult>();
        var ok = (OkObjectResult)result;
        ok.Value.Should().BeOfType<DeckDetailDto>()
            .Which.Slug.Should().Be("deck-detail");
    }

    [Fact]
    public async Task GetCardsBySlug_Should_Return_Ordered_Cards()
    {
        await using var handle = SqliteInMemoryFactory.Create<VocabularyDbContext>();
        var ctx = handle.Context;
        var deckId = Guid.NewGuid();
        ctx.Decks.Add(new Deck
        {
            Id = deckId,
            Slug = "deck-cards",
            Title = "Deck Cards",
            Category = DeckCategory.Ielts,
            Status = DeckStatus.Published,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        });
        ctx.Cards.AddRange(
            new Card { Id = Guid.NewGuid(), DeckId = deckId, Idx = 2, FrontMd = "F2", BackMd = "B2" },
            new Card { Id = Guid.NewGuid(), DeckId = deckId, Idx = 1, FrontMd = "F1", BackMd = "B1" }
        );
        await ctx.SaveChangesAsync();

        var svc = new PublicService(ctx);
        var result = await svc.GetCardsBySlug("deck-cards", CancellationToken.None);

        result.Should().BeOfType<OkObjectResult>();
        var ok = (OkObjectResult)result;
        var cards = ok.Value.Should().BeAssignableTo<List<CardItemDto>>().Subject;
        cards.Should().HaveCount(2);
        cards.Select(c => c.idx).Should().Equal(1, 2);
    }
}
