using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
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
using speaking_service.Contracts;
using speaking_service.Domains.Entities;
using speaking_service.Features.Services.Admin;
using speaking_service.Features.Services.Helper;
using speaking_service.Infrastructure.Persistence;
using Xunit;

namespace speaking_service.Features.Services.Admin.UnitTests;

public class AdminServiceTests : IDisposable
{
    private readonly Faker _faker;
    private readonly Mock<IHttpClientFactory> _httpClientFactory;
    private readonly Mock<IOptions<OpenRouterOptions>> _options;
    private readonly Mock<IUserContext> _userContext;
    private readonly SpeakingDbContext _context;
    private readonly AdminService _sut;

    public AdminServiceTests()
    {
        _faker = new Faker();
        _httpClientFactory = new Mock<IHttpClientFactory>(MockBehavior.Strict);
        _options = new Mock<IOptions<OpenRouterOptions>>(MockBehavior.Strict);
        _userContext = new Mock<IUserContext>(MockBehavior.Strict);

        var routerOptions = new OpenRouterOptions
        {
            ApiKey = _faker.Internet.Password(24),
            BaseUrl = _faker.Internet.UrlWithPath(),
            Model = _faker.Hacker.Verb()
        };
        _options.SetupGet(o => o.Value).Returns(routerOptions);
        _userContext.SetupGet(u => u.User).Returns(new System.Security.Claims.ClaimsPrincipal());
        _userContext.SetupGet(u => u.UserId).Returns(Guid.NewGuid());

        _context = CreateDbContext();
        _sut = new AdminService(_options.Object, _httpClientFactory.Object, _userContext.Object, _context);
    }

    [Fact]
    public async Task CreateExam_WithValidPayload_ShouldPersistAndReturnOk()
    {
        var request = new Faker<CreateSpeakingExamRequest>()
            .CustomInstantiator(f => new CreateSpeakingExamRequest(
                f.Lorem.Sentence(5),
                f.Lorem.Paragraph(),
                f.PickRandom<SpeakingCategory>(),
                f.Random.String2(2, 6),
                f.Lorem.Word(),
                f.Date.RecentOffset().UtcDateTime,
                Guid.NewGuid()))
            .Generate();

        var result = await _sut.CreateExam(request, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Created exam successfully");

        var stored = await _context.SpeakingExams.SingleAsync();
        stored.Title.Should().Be(request.Title);
        stored.TaskText.Should().Be(request.TaskText);
        stored.ExamType.Should().Be(request.ExamType);
        stored.Level.Should().Be(request.Level);
        stored.Tags.Should().Be(request.Tag);
        stored.CreatedBy.Should().Be(request.CreatedBy);
    }

    [Fact]
    public async Task CreateExam_WithInvalidExamType_ShouldThrowInvalidExpression()
    {
        var request = new CreateSpeakingExamRequest(
            _faker.Lorem.Sentence(),
            _faker.Lorem.Paragraph(),
            (SpeakingCategory)_faker.Random.Int(10, 20),
            _faker.Random.String2(3, 7),
            _faker.Lorem.Word(),
            _faker.Date.RecentOffset().UtcDateTime,
            Guid.NewGuid());

        var act = async () => await _sut.CreateExam(request, CancellationToken.None);

        await act.Should().ThrowAsync<InvalidExpressionException>();
        _context.SpeakingExams.Should().BeEmpty();
    }

    [Fact]
    public async Task UpdateExam_WhenExamExists_ShouldUpdateFields()
    {
        var exam = new SpeakingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = SpeakingCategory.TOEIC,
            Level = _faker.Random.String2(3, 7),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.PastOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        _context.SpeakingExams.Add(exam);
        await _context.SaveChangesAsync();

        var updateRequest = new Faker<UpdateSpeakingExamRequest>()
            .CustomInstantiator(f => new UpdateSpeakingExamRequest(
                f.Lorem.Sentence(4),
                f.Lorem.Paragraph(),
                f.PickRandom(new[] { SpeakingCategory.SPEAKING_PART1, SpeakingCategory.SPEAKING_PART2 }),
                f.Random.String2(2, 6),
                f.Lorem.Word()))
            .Generate();

        var result = await _sut.UpdateExam(exam.Id, updateRequest, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Updated exam successfully");

        var stored = await _context.SpeakingExams.FindAsync(exam.Id);
        stored.Should().NotBeNull();
        stored!.Title.Should().Be(updateRequest.Title);
        stored.TaskText.Should().Be(updateRequest.TaskText);
        stored.ExamType.Should().Be(updateRequest.ExamType);
        stored.Level.Should().Be(updateRequest.Level);
        stored.Tags.Should().Be(updateRequest.Tag);
    }

    [Fact]
    public async Task UpdateExam_WhenExamMissing_ShouldReturnNotFound()
    {
        var request = new UpdateSpeakingExamRequest(
            _faker.Lorem.Sentence(),
            _faker.Lorem.Paragraph(),
            SpeakingCategory.SPEAKING_PART3,
            _faker.Random.String2(2, 6),
            _faker.Lorem.Word());

        var result = await _sut.UpdateExam(Guid.NewGuid(), request, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status404NotFound);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Exam not found");
    }

    [Fact]
    public async Task DeleteExam_WhenSubmissionExists_ShouldReturnBadRequest()
    {
        var examId = Guid.NewGuid();
        _context.SpeakingExams.Add(new SpeakingExam
        {
            Id = examId,
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = SpeakingCategory.TOEIC,
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        });
        _context.SpeakingSubmissions.Add(new SpeakingSubmission
        {
            Id = Guid.NewGuid(),
            ExamId = examId,
            TaskTextSnapshot = _faker.Lorem.Paragraph(),
            TranscriptRaw = _faker.Lorem.Paragraph(),
            TranscriptNormalized = _faker.Lorem.Paragraph(),
            WordCount = _faker.Random.Int(20, 200),
            ExamType = SpeakingCategory.TOEIC,
            SubmittedAt = _faker.Date.RecentOffset().UtcDateTime
        });
        await _context.SaveChangesAsync();

        var result = await _sut.DeleteExam(examId, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status400BadRequest);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Cannot delete exam with existing submissions");

        (await _context.SpeakingExams.AnyAsync(x => x.Id == examId)).Should().BeTrue();
    }

    [Fact]
    public async Task DeleteExam_WhenNoSubmission_ShouldRemoveExam()
    {
        var exam = new SpeakingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = SpeakingCategory.SPEAKING_PART2,
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        _context.SpeakingExams.Add(exam);
        await _context.SaveChangesAsync();

        var result = await _sut.DeleteExam(exam.Id, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Deleted exam successfully");

        (await _context.SpeakingExams.AnyAsync(x => x.Id == exam.Id)).Should().BeFalse();
    }

    [Fact]
    public async Task GetAllExams_ShouldReturnDescendingByCreatedAt()
    {
        var recent = new SpeakingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = SpeakingCategory.TOEIC,
            Level = _faker.Random.String2(2, 6),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        var older = new SpeakingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = SpeakingCategory.SPEAKING_PART1,
            Level = _faker.Random.String2(2, 6),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.PastOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        _context.SpeakingExams.AddRange(recent, older);
        await _context.SaveChangesAsync();

        var result = await _sut.GetAllExams(CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Fetched all speaking exams");

        var responses = payload.data.Should().BeAssignableTo<IEnumerable<SpeakingExamResponse>>().Which.ToList();
        responses.Should().HaveCount(2);
        responses.Should().BeInDescendingOrder(x => x.CreatedAt);
        responses.First().Id.Should().Be(recent.Id);
        responses.Last().Id.Should().Be(older.Id);
    }

    private static SpeakingDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<SpeakingDbContext>()
            .UseInMemoryDatabase($"speaking-tests-{Guid.NewGuid()}")
            .Options;
        return new SpeakingDbContext(options);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
