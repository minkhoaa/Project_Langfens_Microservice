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
using vocabulary_service.Application.Helper;
using vocabulary_service.Contracts.User;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;
using Xunit;

namespace VocabularyService.UnitTests.User;

public class UserServiceTests : IDisposable
{
    private readonly Faker _faker = new();
    private readonly VocabularyDbContext _db;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _db = CreateDbContext();
        _sut = new UserService(_db);
    }

    [Fact]
    public async Task SubscribeDecks_WhenDeckMissing_ShouldReturn404()
    {
        var result = await _sut.SubscribeDecks(Guid.NewGuid(), Guid.NewGuid(), CancellationToken.None);

        ResultAssert.Api(result).StatusCode.Should().Be(StatusCodes.Status404NotFound);
    }

    [Fact]
    public async Task SubscribeDecks_ShouldCreateOrReactivate()
    {
        var deck = SeedDeck();
        var userId = Guid.NewGuid();
        await _db.SaveChangesAsync();

        var first = ResultAssert.Api(await _sut.SubscribeDecks(deck.Id, userId, CancellationToken.None));
        first.StatusCode.Should().Be(StatusCodes.Status200OK);
        var created = await _db.UserDecks.SingleAsync();
        created.Status.Should().Be(UserDeckStatus.Active);

        created.Status = "PAUSED";
        await _db.SaveChangesAsync();

        var second = ResultAssert.Api(await _sut.SubscribeDecks(deck.Id, userId, CancellationToken.None));
        second.Payload.isSuccess.Should().BeTrue();
        (await _db.UserDecks.SingleAsync()).Status.Should().Be(UserDeckStatus.Active);
    }

    [Fact]
    public async Task GetDueFlashcard_WhenNoDecks_ShouldReturnEmpty()
    {
        var (status, payload) = ResultAssert.Api(await _sut.GetDueFlashcard(Guid.NewGuid(), CancellationToken.None));
        status.Should().Be(StatusCodes.Status200OK);
        payload.data.Should().BeAssignableTo<IEnumerable<DueCardDto>>().Which.Should().BeEmpty();
    }

    [Fact]
    public async Task GetDueFlashcard_ShouldReturnOrderedLimitedDueItems()
    {
        var userId = Guid.NewGuid();
        var deck = SeedDeck();
        _db.UserDecks.Add(new UserDeck { Id = deck.Id, DeckId = deck.Id, UserId = userId, Status = UserDeckStatus.Active, SubscribeAt = DateTime.UtcNow });
        var cards = Enumerable.Range(1, 3).Select(i => new Card
        {
            Id = Guid.NewGuid(),
            DeckId = deck.Id,
            Idx = i,
            FrontMd = $"F{i}",
            BackMd = $"B{i}",
            HintMd = $"H{i}"
        }).ToList();
        _db.Cards.AddRange(cards);
        _db.UserCardReviews.AddRange(
            new UserCardReview { Id = Guid.NewGuid(), UserId = userId, CardId = cards[0].Id, DueAt = DateTime.UtcNow.Date.AddDays(-1) },
            new UserCardReview { Id = Guid.NewGuid(), UserId = userId, CardId = cards[1].Id, DueAt = DateTime.UtcNow.Date },
            new UserCardReview { Id = Guid.NewGuid(), UserId = userId, CardId = cards[2].Id, DueAt = DateTime.UtcNow.Date.AddDays(1) }
        );
        await _db.SaveChangesAsync();

        var (status, payload) = ResultAssert.Api(await _sut.GetDueFlashcard(userId, CancellationToken.None, limit: 2));

        status.Should().Be(StatusCodes.Status200OK);
        var due = payload.data.Should().BeAssignableTo<IEnumerable<DueCardDto>>().Which.ToList();
        due.Should().HaveCount(2);
        due.Select(d => d.Id).Should().Contain(cards[0].Id);
        due.Select(d => d.Id).Should().Contain(cards[1].Id);
    }

    [Fact]
    public async Task ReviewFlashcard_WhenCardMissing_ShouldReturn404()
    {
        var result = await _sut.ReviewFlashcard(Guid.NewGuid(), Guid.NewGuid(),
            new ReviewRequest(3), CancellationToken.None);

        ResultAssert.Api(result).StatusCode.Should().Be(StatusCodes.Status404NotFound);
    }

    [Fact]
    public async Task ReviewFlashcard_WhenNotSubscribed_ShouldReturnForbidden()
    {
        var deck = SeedDeck();
        var card = new Card { Id = Guid.NewGuid(), DeckId = deck.Id, FrontMd = "f", BackMd = "b", Idx = 1 };
        _db.Cards.Add(card);
        await _db.SaveChangesAsync();

        var result = await _sut.ReviewFlashcard(Guid.NewGuid(), card.Id, new ReviewRequest(3), CancellationToken.None);

        ResultAssert.Api(result).StatusCode.Should().Be(StatusCodes.Status403Forbidden);
    }

    [Fact]
    public async Task ReviewFlashcard_ShouldApplySm2AndLog()
    {
        var userId = Guid.NewGuid();
        var deck = SeedDeck();
        var card = new Card { Id = Guid.NewGuid(), DeckId = deck.Id, FrontMd = "f", BackMd = "b", Idx = 1 };
        _db.Cards.Add(card);
        _db.UserDecks.Add(new UserDeck { Id = deck.Id, UserId = userId, DeckId = deck.Id, Status = UserDeckStatus.Active, SubscribeAt = DateTime.UtcNow });
        await _db.SaveChangesAsync();

        var (status, payload) = ResultAssert.Api(await _sut.ReviewFlashcard(userId, card.Id, new ReviewRequest(5), CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        var response = payload.data.Should().BeOfType<ReviewResponse>().Subject;
        response.CardId.Should().Be(card.Id);

        var review = await _db.UserCardReviews.SingleAsync();
        review.TotalReviews.Should().Be(1);
        review.Repetition.Should().Be(1);
        review.IntervalDays.Should().Be(1);
        _db.ReviewLogs.Count().Should().Be(1);
    }

    private Deck SeedDeck()
    {
        var deck = new Deck
        {
            Id = Guid.NewGuid(),
            Slug = _faker.Lorem.Slug(),
            Title = _faker.Commerce.ProductName(),
            DescriptionMd = _faker.Lorem.Sentence(),
            Category = DeckCategory.Ielts,
            Status = DeckStatus.Published,
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
            .UseInMemoryDatabase($"vocab-user-tests-{Guid.NewGuid()}")
            .Options;
        return new VocabularyDbContext(options);
    }

    public void Dispose()
    {
        _db.Dispose();
    }
}
