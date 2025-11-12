using System.Security.Claims;

namespace AttemptService.UnitTests.Attempt;

public class AttemptSubmitTests
{
    [Fact]
    public async Task Submit_Should_Return_NotFound_When_Attempt_Missing()
    {
        await using var ctx = AttemptDbContextFactory.Create();
        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());

        var principal = new ClaimsPrincipal(new ClaimsIdentity([new Claim("sub", Guid.NewGuid().ToString())]));
        var (status, payload) = ResultAssert.Api(
            await service.Submit(Guid.NewGuid(), principal, CancellationToken.None));

        status.Should().Be(StatusCodes.Status404NotFound);
        payload.message.Should().Contain("Not found");
    }

    [Fact]
    public async Task Submit_Should_Grade_Answers_And_Set_Status()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var proto = SnapshotFactory.CreateProtoExam();
        var sectionId = Guid.Parse(proto.Sections[0].Id);
        var question = proto.Sections[0].Questions[0];
        var questionId = Guid.Parse(question.Id);
        var correctOption = Guid.Parse(question.Options[0].Id);

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.Parse(proto.Id),
            Status = AttemptStatus.InProgress,
            StartedAt = DateTime.UtcNow,
            DurationSec = proto.DurationMin * 60,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(proto)!)
        });

        ctx.AttemptAnswers.Add(new AttemptAnswer
        {
            AttemptId = attemptId,
            SectionId = sectionId,
            QuestionId = questionId,
            SelectedOptionIds = new List<Guid> { correctOption }
        });

        await ctx.SaveChangesAsync();

        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());

        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId.ToString()) }));
        var (status, payload) = ResultAssert.Api(
            await service.Submit(attemptId, principal, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("Submitted");
        var json = payload.data.ToJsonElement();
        json.GetProperty("status").GetString().Should().Be(AttemptStatus.Graded);

        var attempt = await ctx.Attempts.FindAsync(attemptId);
        attempt!.Status.Should().Be(AttemptStatus.Graded);
        attempt.RawScore.Should().BeGreaterThan(0);
        attempt.SubmittedAt.Should().NotBeNull();
    }
}
