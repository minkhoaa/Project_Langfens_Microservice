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
        var (statusCode, api) = ResultHelpers.Extract<ApiResultDto>(result);

        statusCode.Should().Be(StatusCodes.Status400BadRequest);
        api!.isSuccess.Should().BeFalse();
    }
}
