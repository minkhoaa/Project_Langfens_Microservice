using attempt_service.Domain.Entities;
using attempt_service.Domain.Enums;
using attempt_service.Features.Attempt.AttemptEndpoint;

namespace AttemptService.UnitTests.Attempt;

public class AttemptSubmitExpiredTests
{
    [Fact]
    public async Task Submit_Should_Return_Conflict_And_Mark_Expired_When_Time_Passed()
    {
        var ctx = AttemptDbContextFactory.Create();
        var userId = Guid.NewGuid().ToString();
        var attemptId = Guid.NewGuid();
        ctx.Attempts.Add(new Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.NewGuid(),
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow.AddMinutes(-120),
            DurationSec = 60,
            PaperJson = JsonDocument.Parse("{}")
        });
        await ctx.SaveChangesAsync();

        var svc = new attempt_service.Features.Attempt.AttemptEndpoint.AttemptService(
            ctx,
            Mock.Of<IExamGateway>(),
            Mock.Of<IUserContext>(u => u.UserId == userId),
            Mock.Of<IAnswerKeyBuilder>(),
            Mock.Of<IIndexBuilder>(),
            Mock.Of<IAnswerValidator>(),
            Mock.Of<IPlacementWorkflow>(),
            Mock.Of<IQuestionGraderFactory>());

        var result = await svc.Submit(attemptId, CancellationToken.None);
        var (status, api) = ResultAssert.Api(result);

        status.Should().Be(StatusCodes.Status409Conflict);
        api!.isSuccess.Should().BeFalse();

        var updated = await ctx.Attempts.FindAsync(attemptId);
        updated!.Status.Should().Be(AttemptStatus.Expired);
    }
}
