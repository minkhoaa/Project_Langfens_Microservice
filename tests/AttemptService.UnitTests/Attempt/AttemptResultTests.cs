using System.Security.Claims;

namespace AttemptService.UnitTests.Attempt;

public class AttemptResultTests
{
    [Fact]
    public async Task GetResult_Should_Return_Conflict_When_Not_Submitted()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var proto = SnapshotFactory.CreateProtoExam();

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.Parse(proto.Id),
            Status = AttemptStatus.InProgress,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(proto)!)
        });
        await ctx.SaveChangesAsync();

        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());
        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId.ToString()) }));
        var (status, payload) = ResultAssert.Api(
            await service.GetResult(attemptId, principal, CancellationToken.None));

        status.Should().Be(StatusCodes.Status409Conflict);
        payload.message.Should().Contain("not submitted");
    }

    [Fact]
    public async Task GetResult_Should_Return_Report_For_Submitted_Attempt()
    {
        var userId = Guid.NewGuid();
        var attemptId = Guid.NewGuid();
        var proto = SnapshotFactory.CreateProtoExam();
        var sectionId = Guid.Parse(proto.Sections[0].Id);
        var questionId = Guid.Parse(proto.Sections[0].Questions[0].Id);

        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.Add(new attempt_service.Domain.Entities.Attempt
        {
            Id = attemptId,
            UserId = userId,
            ExamId = Guid.Parse(proto.Id),
            Status = AttemptStatus.Submitted,
            SubmittedAt = DateTime.UtcNow,
            PaperJson = JsonDocument.Parse(JsonFormatter.Default.Format(proto)!),
            Answers = new List<AttemptAnswer>
            {
                new()
                {
                    AttemptId = attemptId,
                    SectionId = sectionId,
                    QuestionId = questionId,
                    SelectedOptionIds = new List<Guid>(),
                    IsCorrect = true,
                    AwardedPoints = 1m
                }
            }
        });
        await ctx.SaveChangesAsync();

        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());
        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId.ToString()) }));
        var (status, payload) = ResultAssert.Api(
            await service.GetResult(attemptId, principal, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        var response = payload.data as AttemptResultResponse;
        response.Should().NotBeNull();
        response!.Answers.Should().HaveCount(1);
        response.Total.Should().BeGreaterThan(0);
        response.ScoreRaw.Should().BeGreaterThanOrEqualTo(0);
    }

    [Fact]
    public async Task GetAttemptList_Should_Paginate_And_Project_Items()
    {
        var userId = Guid.NewGuid();
        await using var ctx = AttemptDbContextFactory.Create();

        ctx.Attempts.AddRange(new[]
        {
            new attempt_service.Domain.Entities.Attempt
            {
                UserId = userId,
                ExamId = Guid.NewGuid(),
                Status = AttemptStatus.Started,
                DurationSec = 600,
                StartedAt = DateTime.UtcNow.AddMinutes(-5),
                PaperJson = JsonDocument.Parse("""{"sections":[]}""")
            },
            new attempt_service.Domain.Entities.Attempt
            {
                UserId = userId,
                ExamId = Guid.NewGuid(),
                Status = AttemptStatus.Graded,
                StartedAt = DateTime.UtcNow.AddHours(-2),
                DurationSec = 600,
                PaperJson = JsonDocument.Parse("""{"sections":[]}"""),
                SubmittedAt = DateTime.UtcNow.AddHours(-1),
                ScaledScore = 75
            }
        });
        await ctx.SaveChangesAsync();

        var service = new AttemptServiceImpl(ctx, Mock.Of<IExamGateway>());
        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim("sub", userId.ToString()) }));
        var (status, payload) = ResultAssert.Api(
            await service.GetAttemptList(principal, page: 1, pageSize: 10, status: null, examId: null, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        var items = payload.data as List<AttemptListItem>;
        items.Should().NotBeNull();
        items!.Count.Should().Be(2);
    }
}
