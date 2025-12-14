extern alias ExamService;
using System.Text.Json;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Grpc.Net.Client;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Shared.Grpc.ExamInternal;
using System.Security.Claims;
using System.Text.Encodings.Web;
using ExamService::exam_service.Domains.Entities;
using ExamService::exam_service.Infrastructure.Persistence;
using Xunit;

namespace IntegrationTests.Exam;

public class ExamGrpcTests : IClassFixture<ExamGrpcFactory>
{
    private readonly ExamGrpcFactory _factory;
    private readonly Faker _faker = new();

    public ExamGrpcTests(ExamGrpcFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task GetInternalExam_ShouldReturnExamProto()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext>();
        var exam = SeedExam(db);
        await db.SaveChangesAsync();

        var client = CreateGrpcClient();
        var response = await client.GetInternalExamAsync(new GetInternalExamRequest
        {
            ExamId = exam.Id.ToString(),
            ShowAnswers = true
        });

        response.Should().NotBeNull();
        response.Id.Should().Be(exam.Id.ToString());
        response.Sections.Count.Should().Be(1);
        response.Sections.First().Questions.Count.Should().Be(1);
    }

    private ExamInternal.ExamInternalClient CreateGrpcClient()
    {
        var handler = _factory.Server.CreateHandler();
        var channel = GrpcChannel.ForAddress("http://localhost", new GrpcChannelOptions
        {
            HttpHandler = handler
        });
        return new ExamInternal.ExamInternalClient(channel);
    }

    private ExamService::exam_service.Domains.Entities.Exam SeedExam(ExamService::exam_service.Infrastructure.Persistence.ExamDbContext db)
    {
        var exam = new ExamService::exam_service.Domains.Entities.Exam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Commerce.ProductName(),
            Slug = _faker.Lorem.Slug(),
            Category = "IELTS",
            Level = "B1",
            Status = "Published",
            UpdatedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
        var section = new ExamSection
        {
            Id = Guid.NewGuid(),
            ExamId = exam.Id,
            Title = "Sec",
            Idx = 1
        };
        var questionId = Guid.NewGuid();
        var question = new ExamQuestion
        {
            Id = questionId,
            SectionId = section.Id,
            Idx = 1,
            Type = "MULTIPLE_CHOICE_SINGLE",
            Skill = "READING",
            PromptMd = _faker.Lorem.Sentence(),
            ExplanationMd = "exp"
        };
        question.Options.Add(new ExamOption
        {
            Id = Guid.NewGuid(),
            QuestionId = questionId,
            Idx = 1,
            ContentMd = "A",
            IsCorrect = true
        });
        section.Questions.Add(question);
        exam.Sections.Add(section);
        db.Exams.Add(exam);
        return exam;
    }
}

public class ExamGrpcFactory : WebApplicationFactory<ExamService::Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureServices(services =>
        {
            services.RemoveAll(typeof(DbContextOptions<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext>));
            services.RemoveAll(typeof(ExamService::exam_service.Infrastructure.Persistence.ExamDbContext));
            services.RemoveAll(typeof(IDbContextFactory<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext>));
            var pooledDescriptors = services
                .Where(d => d.ServiceType.FullName?.Contains("DbContextPool") == true
                            || d.ServiceType.FullName?.Contains("ScopedDbContextLease") == true)
                .ToList();
            foreach (var descriptor in pooledDescriptors)
            {
                services.Remove(descriptor);
            }

            services.AddEntityFrameworkInMemoryDatabase();
            services.AddScoped<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext>(_ =>
            {
                var options = new DbContextOptionsBuilder<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext>()
                    .UseInMemoryDatabase("exam-grpc-tests")
                    .Options;
                return new TestExamDbContext(options);
            });
            services.AddAuthentication("Test")
                .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>("Test", _ => { });
            services.PostConfigure<AuthenticationOptions>(o =>
            {
                o.DefaultAuthenticateScheme = "Test";
                o.DefaultChallengeScheme = "Test";
            });
        });
    }

    private class TestExamDbContext : ExamService::exam_service.Infrastructure.Persistence.ExamDbContext
    {
        public TestExamDbContext(DbContextOptions<ExamService::exam_service.Infrastructure.Persistence.ExamDbContext> options)
            : base(options)
        {
        }

        private static string? SerializeDict(Dictionary<string, string[]?>? value) =>
            value == null ? null : JsonSerializer.Serialize(value, (JsonSerializerOptions?)null);

        private static Dictionary<string, string[]?>? DeserializeDict(string? value) =>
            string.IsNullOrWhiteSpace(value)
                ? null
                : JsonSerializer.Deserialize<Dictionary<string, string[]?>>(value!)!;

        private static string? SerializeList(List<string>? value) =>
            value == null ? null : JsonSerializer.Serialize(value, (JsonSerializerOptions?)null);

        private static List<string> DeserializeList(string? value) =>
            string.IsNullOrWhiteSpace(value)
                ? new List<string>()
                : JsonSerializer.Deserialize<List<string>>(value!) ?? new List<string>();

        protected override void OnModelCreating(ModelBuilder mb)
        {
            base.OnModelCreating(mb);

            var dictConverter = new ValueConverter<Dictionary<string, string[]?>?, string?>(
                v => SerializeDict(v),
                v => DeserializeDict(v));
            var dictComparer = new ValueComparer<Dictionary<string, string[]?>?>(
                (l, r) => SerializeDict(l) == SerializeDict(r),
                v => (SerializeDict(v) ?? string.Empty).GetHashCode(),
                v => DeserializeDict(SerializeDict(v)));

            var listConverter = new ValueConverter<List<string>?, string?>(
                v => SerializeList(v),
                v => DeserializeList(v));
            var listComparer = new ValueComparer<List<string>?>(
                (l, r) => SerializeList(l) == SerializeList(r),
                v => (SerializeList(v) ?? string.Empty).GetHashCode(),
                v => DeserializeList(SerializeList(v)));

            mb.Entity<ExamService::exam_service.Domains.Entities.ExamQuestion>(e =>
            {
                e.Property(x => x.BlankAcceptRegex).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.BlankAcceptTexts).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.MatchPairs).HasConversion(dictConverter).Metadata.SetValueComparer(dictComparer);
                e.Property(x => x.OrderCorrects).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
                e.Property(x => x.ShortAnswerAcceptTexts).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
                e.Property(x => x.ShortAnswerAcceptRegex).HasConversion(listConverter).Metadata.SetValueComparer(listComparer);
            });
        }
    }

    private class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        public TestAuthHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock)
            : base(options, logger, encoder, clock)
        {
        }

        protected override Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            var identity = new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()) }, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);
            return Task.FromResult(AuthenticateResult.Success(ticket));
        }
    }
}
