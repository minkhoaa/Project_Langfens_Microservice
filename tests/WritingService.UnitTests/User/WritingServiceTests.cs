using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Moq;
using Shared.ExamDto.Contracts;
using TestSupport;
using Shared;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Persistence;
using Xunit;

namespace writing_service.Features.Service.User.UnitTests;

public class WritingServiceTests : IDisposable
{
    private readonly Faker _faker = new();
    private readonly Mock<IUserContext> _userContext = new(MockBehavior.Strict);
    private readonly Mock<IHttpClientFactory> _httpClientFactory = new(MockBehavior.Strict);
    private readonly Mock<IOptions<OpenRouterOptions>> _options = new(MockBehavior.Strict);
    private readonly WritingDbContext _db;
    private readonly WritingService _sut;
    private readonly FakeHandler _handler;

    public WritingServiceTests()
    {
        _db = CreateDbContext();
        _userContext.SetupGet(u => u.UserId).Returns(Guid.NewGuid());
        _userContext.SetupGet(u => u.User).Returns(new System.Security.Claims.ClaimsPrincipal());

        var routerOptions = new OpenRouterOptions
        {
            ApiKey = _faker.Internet.Password(32),
            BaseUrl = _faker.Internet.Url(),
            Model = _faker.Hacker.Verb()
        };
        _options.SetupGet(o => o.Value).Returns(routerOptions);

        _handler = new FakeHandler();
        var httpClient = new HttpClient(_handler)
        {
            BaseAddress = new Uri(routerOptions.BaseUrl)
        };
        httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", routerOptions.ApiKey);
        _httpClientFactory.Setup(f => f.CreateClient("openrouter")).Returns(httpClient);

        _sut = new WritingService(_options.Object, _httpClientFactory.Object, _userContext.Object, _db);
    }

    [Fact]
    public async Task StartWritingExam_WithExistingExam_ShouldReturnOk()
    {
        var exam = SeedExam();
        await _db.SaveChangesAsync();

        var result = await _sut.StartWritingExam(exam.Id, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Start successfully");
        var response = payload.data.Should().BeOfType<StartWritingExamResponse>().Subject;
        response.Id.Should().Be(exam.Id);
        response.CreatedBy.Should().Be(exam.CreatedBy);
        response.StartedBy.Should().Be(_userContext.Object.UserId);
    }

    [Fact]
    public async Task GetExam_WhenNotFound_ShouldReturn404()
    {
        var result = await _sut.GetExam(Guid.NewGuid(), CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status404NotFound);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Exam not found");
    }

    [Fact]
    public async Task GetExams_ShouldReturnDescendingList()
    {
        var recent = SeedExam();
        recent.CreatedAt = DateTime.UtcNow;
        var older = SeedExam();
        older.CreatedAt = DateTime.UtcNow.AddDays(-2);
        _db.WritingExams.AddRange(recent, older);
        await _db.SaveChangesAsync();

        var result = await _sut.GetExams(CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Fetched exams successfully");
        var items = payload.data.Should().BeAssignableTo<IEnumerable<WritingExamResponse>>().Which.ToList();
        items.Should().HaveCount(2);
        items.Should().BeInDescendingOrder(x => x.CreatedAt);
        items.First().Id.Should().Be(recent.Id);
    }

    [Fact]
    public async Task GetHistory_ShouldReturnUserSubmissionsOrdered()
    {
        var userId = _userContext.Object.UserId;
        var exam = SeedExam();
        var submissionOld = new WritingSubmission
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ExamId = exam.Id,
            TaskTextSnapshot = exam.TaskText,
            EssayRaw = _faker.Lorem.Paragraph(),
            EssayNormalized = _faker.Lorem.Paragraph(),
            WordCount = _faker.Random.Int(50, 150),
            ExamType = exam.ExamType,
            Level = exam.Level,
            TimeSpentSeconds = _faker.Random.Int(100, 400),
            SubmittedAt = DateTime.UtcNow.AddMinutes(-30)
        };
        var submissionNew = new WritingSubmission
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ExamId = exam.Id,
            TaskTextSnapshot = exam.TaskText,
            EssayRaw = _faker.Lorem.Paragraph(),
            EssayNormalized = _faker.Lorem.Paragraph(),
            WordCount = _faker.Random.Int(50, 150),
            ExamType = exam.ExamType,
            Level = exam.Level,
            TimeSpentSeconds = _faker.Random.Int(100, 400),
            SubmittedAt = DateTime.UtcNow
        };
        _db.WritingSubmissions.AddRange(submissionOld, submissionNew);
        _db.WritingEvaluations.Add(new WritingEvaluation
        {
            Id = Guid.NewGuid(),
            SubmissionId = submissionNew.Id,
            OverallBand = _faker.Random.Double(5, 9),
            CoherenceAndCohesionBand = 6,
            GrammaticalRangeAndAccuracyBand = 6,
            LexicalResourceBand = 6,
            TaskResponseBand = 6,
            Provider = "LLM",
            CreatedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();

        var result = await _sut.GetHistory(CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Fetched writing history successfully");
        var items = payload.data.Should().BeAssignableTo<IEnumerable<WritingHistoryItem>>().Which.ToList();
        items.Should().HaveCount(2);
        items.First().SubmissionId.Should().Be(submissionNew.Id);
        items.Last().SubmissionId.Should().Be(submissionOld.Id);
    }

    [Fact]
    public async Task WritingSubmit_WithValidPayload_ShouldPersistSubmissionAndEvaluation()
    {
        var exam = SeedExam();
        await _db.SaveChangesAsync();

        var request = new WritingSubmissionRequest(exam.Id, _faker.Lorem.Paragraph(), _faker.Random.Int(200, 600));

        var rawScore = new LlmWritingScoreCompact
        {
            OverallBand = _faker.Random.Double(5, 8),
            TaskResponse = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            CoherenceAndCohesion = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            LexicalResource = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            GrammaticalRangeAndAccuracy = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            Suggestions = new List<string> { _faker.Lorem.Sentence() },
            ImprovedParagraph = _faker.Lorem.Paragraph()
        };
        _handler.SetResponse(BuildLlmResponse(rawScore));

        var result = await _sut.WritingSubmit(request, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Submitted");

        var storedSubmission = await _db.WritingSubmissions.SingleAsync();
        storedSubmission.ExamId.Should().Be(exam.Id);
        storedSubmission.EssayRaw.Should().Be(request.Answer);

        var storedEvaluation = await _db.WritingEvaluations.SingleAsync();
        storedEvaluation.SubmissionId.Should().Be(storedSubmission.Id);
        storedEvaluation.OverallBand.Should().Be(rawScore.OverallBand);
    }

    private WritingExam SeedExam()
    {
        var exam = new WritingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = _faker.PickRandom<WritingCategory>(),
            Level = _faker.Random.String2(3, 8),
            Tags = _faker.Lorem.Word(),
            CreatedAt = DateTime.UtcNow,
            CreatedBy = Guid.NewGuid()
        };
        _db.WritingExams.Add(exam);
        return exam;
    }

    private static WritingDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<WritingDbContext>()
            .UseInMemoryDatabase($"writing-user-tests-{Guid.NewGuid()}")
            .Options;
        return new WritingDbContext(options);
    }

    public void Dispose()
    {
        _db.Dispose();
    }

    private static string BuildLlmResponse(LlmWritingScoreCompact raw)
    {
        var payload = new
        {
            choices = new[]
            {
                new
                {
                    message = new
                    {
                        role = "assistant",
                        content = JsonSerializer.Serialize(raw)
                    }
                }
            }
        };
        return JsonSerializer.Serialize(payload);
    }

    private sealed class FakeHandler : HttpMessageHandler
    {
        private HttpResponseMessage _response = new(HttpStatusCode.OK)
        {
            Content = new StringContent("{}", Encoding.UTF8, "application/json")
        };

        public void SetResponse(string body)
        {
            _response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(body, Encoding.UTF8, "application/json")
            };
        }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            return Task.FromResult(_response);
        }
    }
}
