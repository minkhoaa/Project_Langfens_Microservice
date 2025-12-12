extern alias VocabService;
using System.Linq;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Deck;
using VocabService::vocabulary_service.Contracts;
using VocabService::vocabulary_service.Domains.Entities;
using VocabService::vocabulary_service.Infrastructure.Persistence;
using Xunit;

namespace IntegrationTests.Vocabulary;

public class VocabularyApiTests : IClassFixture<VocabWebAppFactory>
{
    private readonly VocabWebAppFactory _factory;
    private readonly Faker _faker = new();

    public VocabularyApiTests(VocabWebAppFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetPublishedDecks_ShouldReturnOkList()
    {
        var client = _factory.CreateClient();
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
        db.Decks.Add(new Deck
        {
            Title = _faker.Commerce.ProductName(),
            Slug = _faker.Lorem.Slug(),
            DescriptionMd = _faker.Lorem.Paragraph(),
            Category = DeckCategory.Ielts,
            Status = DeckStatus.Published,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            UserId = Guid.NewGuid()
        });
        await db.SaveChangesAsync();

        var response = await client.GetAsync("/api/decks?page=1&pageSize=5");

        response.EnsureSuccessStatusCode();
        var decks = await response.Content.ReadFromJsonAsync<List<DeckListItemDto>>();
        decks.Should().NotBeNull();
        decks!.Should().NotBeEmpty();
    }
}

public class VocabWebAppFactory : WebApplicationFactory<VocabService::Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<VocabularyDbContext>));
            if (descriptor is not null) services.Remove(descriptor);

            services.AddDbContext<VocabularyDbContext>(opt =>
                opt.UseInMemoryDatabase("vocab-int-tests"));
        });
    }
}
