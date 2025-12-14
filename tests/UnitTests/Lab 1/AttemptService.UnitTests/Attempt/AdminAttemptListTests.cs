namespace AttemptService.UnitTests.Attempt;

public class AdminAttemptListTests
{
    [Fact]
    public async Task GetAllAttempts_Should_Return_BadRequest_For_Invalid_Status()
    {
        var ctx = AttemptDbContextFactory.Create();
        var svc = new attempt_service.Features.Attempt.AttemptEndpoint.AttemptService(
            ctx,
            Mock.Of<IExamGateway>(),
            Mock.Of<IUserContext>(u => u.UserId == Guid.NewGuid().ToString()),
            Mock.Of<IAnswerKeyBuilder>(),
            Mock.Of<IIndexBuilder>(),
            Mock.Of<IAnswerValidator>(),
            Mock.Of<IPlacementWorkflow>(),
            Mock.Of<IQuestionGraderFactory>());

        var result = await svc.GetAllAttempts(page: 1, pageSize: 10, status: "INVALID", examId: null,
            CancellationToken.None);
        var (statusCode, api) = ResultAssert.Api(result);

        statusCode.Should().Be(StatusCodes.Status400BadRequest);
        api!.isSuccess.Should().BeFalse();
    }

    [Fact]
    public async Task GetAllAttempts_Should_Paginate_For_Valid_Status()
    {
        var ctx = AttemptDbContextFactory.Create();
        var examId = Guid.NewGuid();
        ctx.Attempts.AddRange(new Domain.Entities.Attempt
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid().ToString(),
            ExamId = examId,
            Status = AttemptStatus.Submitted,
            DurationSec = 1200,
            StartedAt = DateTime.UtcNow.AddMinutes(-30),
            SubmittedAt = DateTime.UtcNow.AddMinutes(-5),
            PaperJson = JsonDocument.Parse("{}"),
            RawScore = 5
        });
        await ctx.SaveChangesAsync();

        var svc = new attempt_service.Features.Attempt.AttemptEndpoint.AttemptService(
            ctx,
            Mock.Of<IExamGateway>(),
            Mock.Of<IUserContext>(u => u.UserId == Guid.NewGuid().ToString()),
            Mock.Of<IAnswerKeyBuilder>(),
            Mock.Of<IIndexBuilder>(),
            Mock.Of<IAnswerValidator>(),
            Mock.Of<IPlacementWorkflow>(),
            Mock.Of<IQuestionGraderFactory>());

        var result = await svc.GetAllAttempts(page: 1, pageSize: 5, status: AttemptStatus.Submitted, examId: examId,
            CancellationToken.None);
        var (statusCode, api) = ResultAssert.Api(result);

        statusCode.Should().Be(StatusCodes.Status200OK);
        var payload = api!.data.Should().BeAssignableTo<dynamic>().Subject;
        ((int)payload.page).Should().Be(1);
        ((int)payload.total).Should().BeGreaterThanOrEqualTo(1);
    }
}
