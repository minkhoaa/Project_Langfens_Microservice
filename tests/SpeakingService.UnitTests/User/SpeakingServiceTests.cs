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
using TestSupport;
using Shared.ExamDto.Contracts;
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Helper;
using speaking_service.Features.Services.Helper;
using speaking_service.Features.Services.User;
using speaking_service.Infrastructure.Persistence;
using Xunit;

namespace speaking_service.Features.Services.User.UnitTests;

public class SpeakingServiceTests : IDisposable
{
    private readonly Faker _faker = new();
    private readonly Mock<IUserContext> _userContext = new(MockBehavior.Strict);
    private readonly Mock<IWhisperService> _whisper = new(MockBehavior.Strict);
    private readonly Mock<IHttpClientFactory> _httpClientFactory = new(MockBehavior.Strict);
    private readonly Mock<IOptions<OpenRouterOptions>> _options = new(MockBehavior.Strict);
    private readonly SpeakingDbContext _db;
    private readonly SpeakingService _sut;
    private readonly FakeHandler _handler;

    public SpeakingServiceTests()
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

        _sut = new SpeakingService(_db, _userContext.Object, _options.Object, _whisper.Object, _httpClientFactory.Object);
    }

    [Fact]
    public async Task StartSpeakingExam_WithExistingExam_ShouldReturnOk()
    {
        var exam = SeedExam();
        await _db.SaveChangesAsync();

        var (status, payload) = ResultAssert.Api(await _sut.StartSpeakingExam(exam.Id, CancellationToken.None));
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Start successfully");
        var response = payload.data.Should().BeOfType<StartSpeakingExamResponse>().Subject;
        response.Id.Should().Be(exam.Id);
        response.CreatedBy.Should().Be(exam.CreatedBy);
        response.StartedBy.Should().Be(_userContext.Object.UserId);
    }

    [Fact]
    public async Task GetExam_WhenNotFound_ShouldReturn404()
    {
        var (status, payload) = ResultAssert.Api(await _sut.GetExam(Guid.NewGuid(), CancellationToken.None));
        status.Should().Be(StatusCodes.Status404NotFound);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Exam not found");
    }

    [Fact]
    public async Task GetHistory_ShouldReturnUserSubmissionsOrdered()
    {
        var userId = _userContext.Object.UserId;
        var exam = SeedExam();
        var submissionOld = new SpeakingSubmission
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ExamId = exam.Id,
            TaskTextSnapshot = exam.TaskText,
            TranscriptRaw = _faker.Lorem.Paragraph(),
            TranscriptNormalized = _faker.Lorem.Paragraph(),
            WordCount = _faker.Random.Int(10, 100),
            ExamType = exam.ExamType,
            Level = exam.Level,
            TimeSpentSeconds = _faker.Random.Int(50, 300),
            SubmittedAt = DateTime.UtcNow.AddMinutes(-20)
        };
        var submissionNew = new SpeakingSubmission
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ExamId = exam.Id,
            TaskTextSnapshot = exam.TaskText,
            TranscriptRaw = _faker.Lorem.Paragraph(),
            TranscriptNormalized = _faker.Lorem.Paragraph(),
            WordCount = _faker.Random.Int(10, 100),
            ExamType = exam.ExamType,
            Level = exam.Level,
            TimeSpentSeconds = _faker.Random.Int(50, 300),
            SubmittedAt = DateTime.UtcNow
        };
        _db.SpeakingSubmissions.AddRange(submissionOld, submissionNew);
        _db.SpeakingEvaluations.Add(new SpeakingEvaluation
        {
            Id = Guid.NewGuid(),
            SubmissionId = submissionNew.Id,
            OverallBand = _faker.Random.Double(5, 9),
            FluencyAndCoherenceBand = 6,
            GrammaticalRangeAndAccuracyBand = 6,
            LexicalResourceBand = 6,
            PronunciationBand = 6,
            Provider = "LLM",
            CreatedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();

        var (status, payload) = ResultAssert.Api(await _sut.GetHistory(CancellationToken.None));
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Fetched speaking history successfully");
        var items = payload.data.Should().BeAssignableTo<IEnumerable<SpeakingHistoryItem>>().Which.ToList();
        items.Should().HaveCount(2);
        items.First().SubmissionId.Should().Be(submissionNew.Id);
        items.Last().SubmissionId.Should().Be(submissionOld.Id);
    }

    [Fact]
    public async Task SpeakingSubmit_WithValidAudio_ShouldPersistSubmissionAndEvaluation()
    {
        var exam = SeedExam();
        await _db.SaveChangesAsync();

        var audio = new Mock<IFormFile>(MockBehavior.Strict);
        _whisper.Setup(w => w.Transcript(audio.Object)).ReturnsAsync(_faker.Lorem.Paragraph());

        var llmRaw = new LlmSpeakingScoreCompact
        {
            OverallBand = _faker.Random.Double(5, 9),
            FluencyAndCoherence = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            GrammaticalRangeAndAccuracy = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            LexicalResource = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            Pronunciation = new CriterionArray { Band = 6, Comment = _faker.Lorem.Sentence() },
            Suggestions = new List<string> { _faker.Lorem.Sentence() },
            ImprovedAnswer = _faker.Lorem.Paragraph()
        };
        _handler.SetResponse(BuildLlmResponse(llmRaw));

        var submitForm = new SpeakingSubmitForm
        {
            ExamId = exam.Id,
            TimeSpentSeconds = _faker.Random.Int(60, 600),
            Speech = audio.Object
        };

        var (status, payload) = ResultAssert.Api(await _sut.SpeakingSubmit(submitForm, CancellationToken.None));
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Submitted");

        var storedSubmission = await _db.SpeakingSubmissions.SingleAsync();
        storedSubmission.ExamId.Should().Be(exam.Id);
        storedSubmission.TranscriptRaw.Should().NotBeNullOrEmpty();

        var storedEvaluation = await _db.SpeakingEvaluations.SingleAsync();
        storedEvaluation.SubmissionId.Should().Be(storedSubmission.Id);
        storedEvaluation.OverallBand.Should().Be(llmRaw.OverallBand);
    }

    private SpeakingExam SeedExam()
    {
        var exam = new SpeakingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = _faker.PickRandom<SpeakingCategory>(),
            Level = _faker.Random.String2(2, 6),
            Tags = _faker.Lorem.Word(),
            CreatedAt = DateTime.UtcNow,
            CreatedBy = Guid.NewGuid()
        };
        _db.SpeakingExams.Add(exam);
        return exam;
    }

    private SpeakingDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<SpeakingDbContext>()
            .UseInMemoryDatabase($"speaking-user-tests-{Guid.NewGuid()}")
            .Options;
        return new SpeakingDbContext(options);
    }

    public void Dispose()
    {
        _db.Dispose();
    }

    private static string BuildLlmResponse(LlmSpeakingScoreCompact raw)
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
