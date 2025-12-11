using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using TestSupport;
using vocabulary_service.Contracts.Admin;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Features.Admin;
using vocabulary_service.Infrastructure.Persistence;
using Xunit;

namespace VocabularyService.UnitTests.Admin;

public class AdminServiceTests : IDisposable
{
    private readonly Faker _faker = new();
    private readonly VocabularyDbContext _db;
    private readonly AdminService _sut;

    public AdminServiceTests()
    {
        _db = CreateDbContext();
        _sut = new AdminService(_db);
    }

    [Fact]
    public async Task CreateDeck_ShouldPersistAndReturnSluggedId()
    {
        var req = new CreateDeckRequest(
            _faker.Lorem.Slug(),
            _faker.Commerce.Department(),
            _faker.Commerce.Categories(1).First(),
            _faker.Random.Word(),
            Guid.NewGuid());

        var (status, payload) = ResultAssert.Api(await _sut.CreateDeck(req, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var created = payload.data.Should().BeOfType<DeckCreatedDto>().Subject;
        var deck = await _db.Decks.SingleAsync();
        deck.Slug.Should().Be(req.Slug.ToLowerInvariant());
        created.Id.Should().Be(deck.Id);
    }

    [Fact]
    public async Task UpdateDeck_WhenNotFound_ShouldReturn404()
    {
        var req = new UpdateDeckRequest(_faker.Lorem.Word(), null, null, null);

        var result = await _sut.UpdateDeck(req, Guid.NewGuid(), CancellationToken.None);

        (await ResultAssert.Api(result).StatusCode).Should().Be(StatusCodes.Status404NotFound);
    }

    [Fact]
    public async Task UpdateDeck_WhenFound_ShouldUpdateFields()
    {
        var deck = SeedDeck();
        await _db.SaveChangesAsync();
        var req = new UpdateDeckRequest(
            _faker.Lorem.Slug(),
            _faker.Lorem.Sentence(),
            DeckStatus.Published,
            DeckCategory.Speaking);

        var (status, payload) = ResultAssert.Api(await _sut.UpdateDeck(req, deck.Id, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var stored = await _db.Decks.FindAsync(deck.Id);
        stored!.Slug.Should().Be(req.Slug);
        stored.Title.Should().Be(req.Title);
        stored.Status.Should().Be(req.Status);
    }

    [Fact]
    public async Task MakeDeckPublic_ShouldSetPublishedStatus()
    {
        var deck = SeedDeck(status: DeckStatus.Draft);
        await _db.SaveChangesAsync();

        var result = await _sut.MakeDeckPublic(deck.Id, CancellationToken.None);

        result.Should().BeOfType<NoContent>();
        (await _db.Decks.Where(x => x.Id == deck.Id).Select(x => x.Status).FirstAsync())
            .Should().Be(FlashCardStatus.Published);
    }

    [Fact]
    public async Task CreateCards_ShouldAssignNextIdx()
    {
        var deck = SeedDeck();
        _db.Cards.Add(new Card { DeckId = deck.Id, Idx = 1, FrontMd = _faker.Lorem.Word(), BackMd = _faker.Lorem.Word() });
        await _db.SaveChangesAsync();
        var req = new CreateCardRequest(_faker.Lorem.Sentence(), _faker.Lorem.Sentence(), _faker.Lorem.Word());

        var (status, payload) = ResultAssert.Api(await _sut.CreateCards(deck.Id, req, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var stored = await _db.Cards.Where(c => c.DeckId == deck.Id).OrderByDescending(c => c.Idx).FirstAsync();
        stored.Idx.Should().Be(2);
        stored.HintMd.Should().Be(req.HintMd);
    }

    [Fact]
    public async Task UpdateCards_WhenMissing_ShouldReturnNotFound()
    {
        var req = new UpdateCardRequest(null, null, null, null);

        var result = await _sut.UpdateCards(Guid.NewGuid(), req, CancellationToken.None);

        ResultAssert.Api(result).StatusCode.Should().Be(StatusCodes.Status404NotFound);
    }

    [Fact]
    public async Task UpdateCards_WhenExists_ShouldApplyUpdates()
    {
        var deck = SeedDeck();
        var card = new Card
        {
            DeckId = deck.Id,
            Idx = 1,
            FrontMd = _faker.Lorem.Word(),
            BackMd = _faker.Lorem.Word(),
            HintMd = _faker.Lorem.Word()
        };
        _db.Cards.Add(card);
        await _db.SaveChangesAsync();
        var req = new UpdateCardRequest(3, _faker.Lorem.Sentence(), _faker.Lorem.Sentence(), _faker.Lorem.Word());

        var (status, payload) = ResultAssert.Api(await _sut.UpdateCards(card.Id, req, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var stored = await _db.Cards.FindAsync(card.Id);
        stored!.Idx.Should().Be(3);
        stored.FrontMd.Should().Be(req.FrontMd);
        stored.BackMd.Should().Be(req.BackMd);
        stored.HintMd.Should().Be(req.HintMd);
    }

    private Deck SeedDeck(string? status = null)
    {
        var deck = new Deck
        {
            Id = Guid.NewGuid(),
            Slug = _faker.Lorem.Slug(),
            Title = _faker.Commerce.Department(),
            DescriptionMd = _faker.Lorem.Sentence(),
            Category = DeckCategory.Speaking,
            Status = status ?? DeckStatus.Draft,
            UserId = Guid.NewGuid(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Decks.Add(deck);
        return deck;
    }

    private static VocabularyDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<VocabularyDbContext>()
            .UseInMemoryDatabase($"vocab-tests-{Guid.NewGuid()}")
            .Options;
        return new VocabularyDbContext(options);
    }

    public void Dispose()
    {
        _db.Dispose();
    }
}
