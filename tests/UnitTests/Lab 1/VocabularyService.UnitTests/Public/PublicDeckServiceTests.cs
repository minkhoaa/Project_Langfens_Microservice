using Microsoft.AspNetCore.Mvc;
using vocabulary_service.Features.Public;
using vocabulary_service.Infrastructure.Persistence;
using vocabulary_service.Domains.Entities;
using Shared.ExamDto.Contracts.Deck;
using vocabulary_service.Contracts;

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
}
