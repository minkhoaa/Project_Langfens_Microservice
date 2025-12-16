using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using vocabulary_service.Contracts.Admin;
using vocabulary_service.Domains.Entities;
using vocabulary_service.Features.Admin;
using vocabulary_service.Infrastructure.Persistence;
using Xunit;

namespace VocabularyService.UnitTests.Features.Admin
{
    public class AdminService_Tests : IDisposable
    {
        private readonly VocabularyDbContext _dbContext;
        private readonly AdminService _sut;

        public AdminService_Tests()
        {
            _dbContext = VocabularyContextFactory.CreateInMemory();
            _sut = new AdminService(_dbContext);
        }

        public void Dispose() => _dbContext.Dispose();

        public static IEnumerable<object[]> CreateDeckCases()
        {
            // VF-005
            yield return new object[] { "Title 1", "slug-1", "CAT1", "Desc 1", Guid.NewGuid() };
            yield return new object[] { "Title 2", "slug-2", "CAT2", "Desc 2", Guid.NewGuid() };
            // Fill to 11
            for (int i = 3; i <= 11; i++)
            {
                yield return new object[] { $"Title {i}", $"slug-{i}", "CAT", "Desc", Guid.NewGuid() };
            }
        }

        [Theory(DisplayName = "VF-005: Create Deck")]
        [MemberData(nameof(CreateDeckCases))]
        public async Task CreateDeck_Should_Create_And_Save_Deck(string title, string slug, string cat, string desc, Guid userId)
        {
            // Arrange
            var request = new CreateDeckRequest(slug, title, desc, cat, null, userId);

            // Act
            var result = await _sut.CreateDeck(request, CancellationToken.None);

            // Assert
            var httpResult = result.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = httpResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            apiResult.isSuccess.Should().BeTrue();
            
            var savedDeck = await _dbContext.Decks.FirstOrDefaultAsync(d => d.Slug == slug);
            savedDeck.Should().NotBeNull();
            savedDeck.Title.Should().Be(title);
        }
    }
}
