namespace AttemptService.UnitTests.Attempt;

public class AttemptStartTests
{
    [Fact]
    public async Task StartAttempt_Should_Resume_Existing_Attempt_With_Sanitized_Snapshot()
    {
        var userId = Guid.NewGuid();
        var examId = Guid.NewGuid();
        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            UserId = userId,
            ExamId = examId,
            Status = AttemptStatus.Started,
            DurationSec = 1200,
            StartedAt = DateTime.UtcNow.AddMinutes(-10),
            PaperJson = JsonDocument.Parse("""{"sections": [{"questions": []}]}""")
        });
        await ctx.SaveChangesAsync();

        var gateway = new Mock<IExamGateway>(MockBehavior.Strict);
        var service = new AttemptServiceImpl(ctx, gateway.Object);

        var (status, payload) = ResultAssert.Api(
            await service.StartAttempt(new AttemptStartRequest(examId), CancellationToken.None, userId, TODO));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("previous attempt");
        payload.data.Should().BeOfType<AttemptStartResponse>();
        gateway.Verify(g => g.GetExamSnapshotAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task StartAttempt_Should_Create_New_Attempt_From_Gateway()
    {
        var userId = Guid.NewGuid();
        var examId = Guid.NewGuid();
        await using var ctx = AttemptDbContextFactory.Create();

        var proto = SnapshotFactory.CreateProtoExam();

        var gateway = new Mock<IExamGateway>();
        gateway.Setup(g => g.GetExamSnapshotAsync(examId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(proto);

        var service = new AttemptServiceImpl(ctx, gateway.Object);

        var (status, payload) = ResultAssert.Api(
            await service.StartAttempt(new AttemptStartRequest(examId), CancellationToken.None, userId, TODO));

        status.Should().Be(StatusCodes.Status200OK);
        var response = payload.data as AttemptStartResponse;
        response.Should().NotBeNull();
        response!.DurationSec.Should().Be(proto.DurationMin * 60);

        var stored = await ctx.Attempts.SingleAsync();
        stored.UserId.Should().Be(userId);
        stored.DurationSec.Should().Be(proto.DurationMin * 60);
        stored.PaperJson.Should().NotBeNull();
        gateway.Verify(g => g.GetExamSnapshotAsync(examId, It.IsAny<CancellationToken>()), Times.Once);
    }
}
