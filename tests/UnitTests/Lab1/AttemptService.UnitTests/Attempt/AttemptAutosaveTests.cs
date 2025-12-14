namespace AttemptService.UnitTests.Attempt;

public class AttemptAutosaveTests
{
    [Fact]
    public async Task Autosave_Should_Return_Conflict_When_Attempt_Expired()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.NewGuid(),
            Status = AttemptStatus.Started,
            DurationSec = 60,
            StartedAt = DateTime.UtcNow.AddMinutes(-10),
            PaperJson = JsonDocument.Parse("""{"sections":[]}""")
        });
        await ctx.SaveChangesAsync();

        var service = AttemptServiceFactory.Create(ctx, userId);
        var result = await service.Autosave(attemptId,
            new AutosaveRequest(new List<AnswerItem>(), null), CancellationToken.None);

        var (status, payload) = ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status409Conflict);
        payload.message.Should().Contain("Expired");
    }

    [Fact]
    public async Task Autosave_Should_Return_422_For_Invalid_Answers()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var proto = SnapshotFactory.CreateProtoExam();
        var questionId = Guid.Parse(proto.Sections[0].Questions[0].Id);

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.Parse(proto.Id),
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = proto.DurationMin * 60,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(proto)!)
        });
        await ctx.SaveChangesAsync();

        var service = AttemptServiceFactory.Create(ctx, userId);
        var req = new AutosaveRequest(
            new List<AnswerItem>
            {
                new(questionId, null, new List<Guid> { Guid.NewGuid() }, null)
            }, null);

        var (status, payload) = ResultAssert.Api(
            await service.Autosave(attemptId, req, CancellationToken.None));

        status.Should().Be(StatusCodes.Status422UnprocessableEntity);
        payload.data.Should().NotBeNull();
    }

    [Fact]
    public async Task Autosave_Should_Persist_Answers_And_Move_To_InProgress()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var proto = SnapshotFactory.CreateProtoExam();
        var question = proto.Sections[0].Questions[0];
        var questionId = Guid.Parse(question.Id);
        var optionId = Guid.Parse(question.Options[0].Id);

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.Parse(proto.Id),
            Status = AttemptStatus.Started,
            StartedAt = DateTime.UtcNow,
            DurationSec = proto.DurationMin * 60,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(proto)!)
        });
        await ctx.SaveChangesAsync();

        var service = AttemptServiceFactory.Create(ctx, userId);
        var req = new AutosaveRequest(
            new List<AnswerItem>
            {
                new(questionId, null, new List<Guid> { optionId }, null)
            }, null);

        var (status, payload) = ResultAssert.Api(
            await service.Autosave(attemptId, req, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("Autosaved");

        var stored = await ctx.AttemptAnswers.SingleAsync();
        stored.SelectedOptionIds.Should().ContainSingle().Which.Should().Be(optionId);

        var attempt = await ctx.Attempts.FindAsync(attemptId);
        attempt!.Status.Should().Be(AttemptStatus.InProgress);
    }
}
