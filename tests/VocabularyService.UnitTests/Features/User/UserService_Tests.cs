// Assuming a clean project setup.
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Moq;
using Shared.ExamDto.Contracts;
using vocabulary_service.Contracts.User;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;
using Xunit;

namespace VocabularyService.UnitTests.Features.User
{
    public class UserService_Tests : IDisposable
    {
        private readonly VocabularyDbContext _dbContext;
        private readonly UserService _sut;

        public UserService_Tests()
        {
            _dbContext = VocabularyContextFactory.CreateInMemory();
            _sut = new UserService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        public static IEnumerable<object[]> ReviewFlashcardCases()
        {
            // Covers VF-002, VF-003, VF-004
            // grade, initial reps, initial EF, initial interval -> expected reps, ef, interval
            yield return new object[] { "q=0 (Fail)", 0, 0, 2.5, 0, 100, 1.7, 1 };
            yield return new object[] { "q=1 (Fail)", 1, 2, 2.0, 5, 100, 1.46, 1 }; // EF drops by 0.54
            yield return new object[] { "q=2 (Fail)", 2, 5, 1.5, 20, 100, 1.3, 1 }; // EF drops by 0.32 -> 1.18 -> Floor 1.3
            yield return new object[] { "q=3 (Pass), 1st review", 3, 0, 2.5, 0, 1, 2.36, 1 }; // Updated expectation to match SM2 math (2.5 - 0.14 = 2.36)
            yield return new object[] { "q=4 (Pass), 1st review", 4, 0, 2.5, 0, 1, 2.5, 1 };
            yield return new object[] { "q=5 (Pass), 1st review", 5, 0, 2.5, 0, 1, 2.6, 1 };
            yield return new object[] { "q=3 (Pass), 2nd review", 3, 1, 2.5, 1, 2, 2.36, 6 }; // Updated expectation 2.36
            yield return new object[] { "q=4 (Pass), 2nd review", 4, 1, 2.6, 1, 2, 2.6, 6 };
            yield return new object[] { "q=5 (Pass), 3rd review", 5, 2, 2.7, 6, 3, 2.8, 17 };
            yield return new object[] { "EF Floor", 3, 4, 1.3, 30, 5, 1.3, 39 }; // EF doesn't go below 1.3
            yield return new object[] { "New card (no prior review)", 4, -1, -1, -1, 1, 2.5, 1 }; // Special case for new cards
        }

        [Theory(DisplayName = "VF-002/003/004: ReviewFlashcard - {0}")]
        [MemberData(nameof(ReviewFlashcardCases))]
        public async Task ReviewFlashcard_Should_Apply_SM2_Algorithm(
            string caseName, int grade, int initialReps, double initialEf, int initialInterval,
            int expectedReps, double expectedEf, int expectedInterval)
        {
            _ = caseName;
            // Arrange
            var cardId = Guid.NewGuid();
            var deckId = Guid.NewGuid();
            var userId = Guid.NewGuid();
            
            var deck = new UserDeck { UserId = userId, DeckId = deckId, Status = "ACTIVE" };
            var card = new Card { Id = cardId, DeckId = deckId, FrontMd = "Front", BackMd = "Back" };
            
            _dbContext.UserDecks.Add(deck);
            _dbContext.Cards.Add(card);
            
            if (initialReps != -1) // Not a new card
            {
                _dbContext.UserCardReviews.Add(new UserCardReview 
                { 
                    UserId = userId, 
                    CardId = cardId, 
                    Repetition = initialReps, 
                    EaseFactor = initialEf, 
                    IntervalDays = initialInterval 
                });
            }
            await _dbContext.SaveChangesAsync();

            // Act
            var result = await _sut.ReviewFlashcard(userId, cardId, new ReviewRequest(grade), CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var response = httpResult.Value.Should().BeAssignableTo<ReviewResponse>().Subject;

            response.Repetition.Should().Be(expectedReps);
            response.EaseFactor.Should().BeApproximately(expectedEf, 0.01);
            response.IntervalDays.Should().Be(expectedInterval);
        }
    }
}
