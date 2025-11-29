using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Claims;
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
using Xunit;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Features.Service.Admin;
using writing_service.Infrastructure.Persistence;

namespace WritingService.UnitTests.Services;

public class AdminServiceTests
{
    private readonly Faker _faker = new();
    private readonly Mock<IHttpClientFactory> _httpClientFactoryMock = new(MockBehavior.Strict);
    private readonly Mock<IOptions<OpenRouterOptions>> _optionsMock = new(MockBehavior.Strict);
    private readonly Mock<IUserContext> _userContextMock = new(MockBehavior.Strict);

    public AdminServiceTests()
    {
        var routerOptions = new OpenRouterOptions
        {
            ApiKey = _faker.Internet.Password(32),
            BaseUrl = _faker.Internet.UrlWithPath(),
            Model = _faker.Hacker.Verb()
        };

        _optionsMock.SetupGet(o => o.Value).Returns(routerOptions);

        var claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity());
        _userContextMock.SetupGet(u => u.User).Returns(claimsPrincipal);
        _userContextMock.SetupGet(u => u.UserId).Returns(Guid.NewGuid());
    }

    [Fact]
    public async Task CreateExam_WithValidInput_ShouldPersistExamAndReturnOk()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var request = new Faker<CreateExamRequest>()
            .CustomInstantiator(f => new CreateExamRequest(
                f.Lorem.Sentence(6),
                f.Lorem.Paragraph(),
                f.PickRandom<WritingCategory>(),
                f.Random.String2(3, 8),
                f.Lorem.Word(),
                f.Date.RecentOffset().UtcDateTime,
                Guid.NewGuid()))
            .Generate();

        var result = await service.CreateExam(request, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Created exam successfully");

        var stored = await context.WritingExams.SingleAsync();
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
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var request = new CreateExamRequest(
            _faker.Lorem.Sentence(),
            _faker.Lorem.Paragraph(),
            (WritingCategory)_faker.Random.Int(5, 25),
            _faker.Random.String2(3, 8),
            _faker.Lorem.Word(),
            _faker.Date.RecentOffset().UtcDateTime,
            Guid.NewGuid());

        var action = async () => await service.CreateExam(request, CancellationToken.None);

        await action.Should().ThrowAsync<InvalidExpressionException>();
        context.WritingExams.Should().BeEmpty();
    }

    [Fact]
    public async Task UpdateExam_WhenExamExists_ShouldUpdateFieldsAndReturnOk()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var existingExam = new WritingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = WritingCategory.TOEIC,
            Level = _faker.Random.String2(4, 9),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.PastOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        context.WritingExams.Add(existingExam);
        await context.SaveChangesAsync();

        var updateRequest = new Faker<UpdateExamRequest>()
            .CustomInstantiator(f => new UpdateExamRequest(
                f.Lorem.Sentence(5),
                f.Lorem.Paragraph(),
                f.PickRandom(new[] { WritingCategory.WRITING_TASK1, WritingCategory.WRITING_TASK2 }),
                f.Random.String2(3, 8),
                f.Lorem.Word()))
            .Generate();

        var result = await service.UpdateExam(existingExam.Id, updateRequest, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Updated exam successfully");

        var stored = await context.WritingExams.FindAsync(existingExam.Id);
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
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var missingId = Guid.NewGuid();
        var request = new UpdateExamRequest(
            _faker.Lorem.Sentence(),
            _faker.Lorem.Paragraph(),
            WritingCategory.WRITING_TASK1,
            _faker.Random.String2(3, 8),
            _faker.Lorem.Word());

        var result = await service.UpdateExam(missingId, request, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status404NotFound);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Exam not found");
    }

    [Fact]
    public async Task DeleteExam_WhenExamMissing_ShouldReturnNotFound()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);

        var result = await service.DeleteExam(Guid.NewGuid(), CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status404NotFound);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Exam not found");
    }

    [Fact]
    public async Task DeleteExam_WhenSubmissionExists_ShouldReturnBadRequest()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var examId = Guid.NewGuid();
        context.WritingExams.Add(new WritingExam
        {
            Id = examId,
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = WritingCategory.TOEIC,
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        });
        context.WritingSubmissions.Add(new WritingSubmission
        {
            Id = Guid.NewGuid(),
            ExamId = examId,
            TaskTextSnapshot = _faker.Lorem.Paragraph(),
            EssayRaw = _faker.Lorem.Paragraphs(),
            EssayNormalized = _faker.Lorem.Paragraphs(),
            WordCount = _faker.Random.Int(50, 500),
            SubmittedAt = _faker.Date.RecentOffset().UtcDateTime
        });
        await context.SaveChangesAsync();

        var result = await service.DeleteExam(examId, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status400BadRequest);
        payload.isSuccess.Should().BeFalse();
        payload.message.Should().Contain("Cannot delete exam with existing submissions");

        (await context.WritingExams.AnyAsync(x => x.Id == examId)).Should().BeTrue();
    }

    [Fact]
    public async Task DeleteExam_WhenNoSubmission_ShouldRemoveExamAndReturnOk()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var exam = new WritingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = WritingCategory.WRITING_TASK2,
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        context.WritingExams.Add(exam);
        await context.SaveChangesAsync();

        var result = await service.DeleteExam(exam.Id, CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Deleted exam successfully");

        (await context.WritingExams.AnyAsync(x => x.Id == exam.Id)).Should().BeFalse();
    }

    [Fact]
    public async Task GetAllExams_ShouldReturnOrderedExamResponses()
    {
        await using var context = CreateDbContext();
        var service = CreateService(context);
        var examRecent = new WritingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = WritingCategory.TOEIC,
            Level = _faker.Random.String2(3, 8),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.RecentOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        var examOlder = new WritingExam
        {
            Id = Guid.NewGuid(),
            Title = _faker.Lorem.Sentence(),
            TaskText = _faker.Lorem.Paragraph(),
            ExamType = WritingCategory.WRITING_TASK1,
            Level = _faker.Random.String2(3, 8),
            Tags = _faker.Lorem.Word(),
            CreatedAt = _faker.Date.PastOffset().UtcDateTime,
            CreatedBy = Guid.NewGuid()
        };
        context.WritingExams.AddRange(examRecent, examOlder);
        await context.SaveChangesAsync();

        var result = await service.GetAllExams(CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        payload.message.Should().Contain("Fetched all writing exams");

        var responses = payload.data.Should().BeAssignableTo<IEnumerable<WritingExamResponse>>().Which.ToList();
        responses.Should().HaveCount(2);
        responses.Should().BeInDescendingOrder(x => x.CreatedAt);
        responses.First().Id.Should().Be(examRecent.Id);
        responses.Last().Id.Should().Be(examOlder.Id);
    }

    private AdminService CreateService(WritingDbContext context) =>
        new(_optionsMock.Object, _httpClientFactoryMock.Object, _userContextMock.Object, context);

    private WritingDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<WritingDbContext>()
            .UseInMemoryDatabase($"writing-tests-{Guid.NewGuid()}")
            .Options;
        return new WritingDbContext(options);
    }
}
