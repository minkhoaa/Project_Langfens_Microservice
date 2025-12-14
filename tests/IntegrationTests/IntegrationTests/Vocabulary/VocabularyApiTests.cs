extern alias VocabService;
using System.Linq;
using System.Net;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
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
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "test-issuer");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "test-audience");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "0123456789abcdef0123456789abcdef");
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

    [Fact]
    public async Task SubscribeDeck_Should_Return_Unauthorized_When_NotAuthenticated()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "test-issuer");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "test-audience");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "0123456789abcdef0123456789abcdef");
        var client = _factory.CreateClient();

        var response = await client.PostAsync($"/api/users/{Guid.NewGuid()}/subscribe/{Guid.NewGuid()}", content: null);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}

public class VocabWebAppFactory : WebApplicationFactory<VocabService::Program>
{
    static VocabWebAppFactory()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "test-issuer");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "test-audience");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "0123456789abcdef0123456789abcdef");
    }

    public VocabWebAppFactory()
    {
        Environment.SetEnvironmentVariable("JwtSettings__Issuer", "test-issuer");
        Environment.SetEnvironmentVariable("JwtSettings__Audience", "test-audience");
        Environment.SetEnvironmentVariable("JwtSettings__SignKey", "0123456789abcdef0123456789abcdef");
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            services.RemoveAll(typeof(IConfigureOptions<JwtBearerOptions>));
            services.RemoveAll(typeof(IPostConfigureOptions<JwtBearerOptions>));
            services.AddAuthentication("Test")
                .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>("Test", _ => { });
            services.PostConfigure<AuthenticationOptions>(o =>
            {
                o.DefaultAuthenticateScheme = "Test";
                o.DefaultChallengeScheme = "Test";
            });

            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<VocabularyDbContext>));
            if (descriptor is not null) services.Remove(descriptor);

            services.AddDbContext<VocabularyDbContext>(opt =>
                opt.UseInMemoryDatabase("vocab-int-tests"));
        });
    }

    private class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        public TestAuthHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger,
            UrlEncoder encoder, ISystemClock clock)
            : base(options, logger, encoder, clock)
        {
        }

        protected override Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            var header = Request.Headers.Authorization.ToString();
            if (string.IsNullOrWhiteSpace(header))
                return Task.FromResult(AuthenticateResult.Fail("missing token"));

            var identity = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Role, "User")
            }, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);
            return Task.FromResult(AuthenticateResult.Success(ticket));
        }
    }
}
