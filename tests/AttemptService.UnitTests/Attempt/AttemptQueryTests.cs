using System.Security.Claims;

namespace AttemptService.UnitTests.Attempt;

public class AttemptQueryTests
{
    [Fact]
    public async Task GetAttemptById_Should_Return_NotFound_When_Attempt_Missing()
    {
        await using var ctx = AttemptDbContextFactory.Create();
        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());

        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", Guid.NewGuid().ToString()) }));
        var (status, payload) = ResultAssert.Api(await service.GetAttemptById(
            new AttemptGetRequest(Guid.NewGuid(), principal), CancellationToken.None));

        status.Should().Be(StatusCodes.Status404NotFound);
        payload.message.Should().Contain("Not found");
    }

    [Fact]
    public async Task GetAttemptById_Should_Return_Sanitized_Dto_Snapshot()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var dtoExam = SnapshotFactory.CreateDtoExam();
        var questionId = dtoExam.Sections[0].Questions[0].Id;

        using var doc = JsonSerializer.SerializeToDocument(dtoExam, new JsonSerializerOptions(JsonSerializerDefaults.Web));

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = dtoExam.Id,
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = dtoExam.DurationMin * 60,
            PaperJson = JsonDocument.Parse(doc.RootElement.GetRawText())
        });
        ctx.AttemptAnswers.Add(new AttemptAnswer
        {
            AttemptId = attemptId,
            QuestionId = questionId,
            SectionId = dtoExam.Sections[0].Id,
            SelectedOptionIds = new List<Guid> { dtoExam.Sections[0].Questions[0].Options![0].Id }
        });
        await ctx.SaveChangesAsync();

        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());
        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId.ToString()) }));
        var (status, payload) = ResultAssert.Api(await service.GetAttemptById(
            new AttemptGetRequest(attemptId, principal), CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        var response = payload.data as AttemptGetResponse;
        response.Should().NotBeNull();
        response!.Answers.Should().HaveCount(1);
        response.Paper.GetProperty("sections").EnumerateArray().Should().NotBeEmpty();
    }
}
