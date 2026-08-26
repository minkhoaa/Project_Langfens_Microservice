using System.Text.Json;
using attempt_service.Domain.Entities;
using attempt_service.Features.Attempt;
using attempt_service.Features.Helpers;
using attempt_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Xunit;

namespace attempt_service.Tests.Integration;

/// <summary>
/// End-to-end integration tests for <see cref="AttemptFlow.SubmitAsync"/>:
/// Load (DbContext + paper snapshot) → Grade (real <see cref="GraderRegistry"/>
/// with all 21 production graders + <see cref="AnswerEnvelopeReader"/>) →
/// Persist (RawScore / ScaledScore / awarded-points on each
/// <see cref="AttemptAnswer"/>) → Publish (MassTransit
/// <see cref="IPublishEndpoint"/>). The host wires everything except
/// <c>IExamGateway</c> (mocked with canned correct-answer envelopes) and
/// <c>RagExplainer</c>'s <see cref="IHttpClientFactory"/> (returns a no-op
/// <see cref="HttpClient"/> so the fire-and-forget RAG call fails fast
/// without blocking). The Theory covers 5 representative question-type
/// slugs across the four canonical skill families that the production
/// graders auto-score.
/// </summary>
public sealed class AttemptServiceFlowTests
{
    private const string TestUserId = "00000000-0000-0000-0000-000000000001";

    private static (AttemptDbContext db, GraderRegistry graders, AnswerEnvelopeReader reader)
        BuildCore()
    {
        var dbOpts = new DbContextOptionsBuilder<AttemptDbContext>()
            .UseInMemoryDatabase($"attempt-flow-{Guid.NewGuid():N}")
            .Options;
        var db = new AttemptDbContext(dbOpts);
        db.Database.EnsureCreated();

        var graders = new GraderRegistry(new IGrader[]
        {
            new MultipleChoiceSingleGrader(),
            new MultipleChoiceSingleImageGrader(),
            new MultipleChoiceMultipleGrader(),
            new TrueFalseNotGivenGrader(),
            new YesNoNotGivenGrader(),
            new SummaryCompletionGrader(new TextNormalizer()),
            new TableCompletionGrader(new TextNormalizer()),
            new NoteCompletionGrader(new TextNormalizer()),
            new FormCompletionGrader(new TextNormalizer()),
            new SentenceCompletionGrader(new TextNormalizer()),
            new ShortAnswerGrader(new TextNormalizer()),
            new AudioResponseGrader(),
            new DiagramLabelGrader(),
            new MapLabelGrader(),
            new MatchingHeadingGrader(),
            new MatchingInformationGrader(),
            new MatchingFeaturesGrader(),
            new MatchingEndingsGrader(),
            new ClassificationGrader(),
            new FlowChartGrader(),
            new FlowChartCompletionGrader(),
        });
        var reader = new AnswerEnvelopeReader();
        return (db, graders, reader);
    }

    private static AttemptFlow BuildFlow(
        AttemptDbContext db,
        GraderRegistry graders,
        AnswerEnvelopeReader reader,
        Mock<IExamGateway> examGw,
        Mock<IPublishEndpoint> bus)
    {
        var httpFactory = new Mock<IHttpClientFactory>();
        httpFactory.Setup(f => f.CreateClient(It.IsAny<string>())).Returns(new HttpClient());
        var rag = new RagExplainer(db, httpFactory.Object, NullLogger<RagExplainer>.Instance);

        var calc = new GradeCalculator();
        var log = NullLogger<AttemptFlow>.Instance;
        return new AttemptFlow(db, examGw.Object, graders, reader, calc, rag, bus.Object, log);
    }

    private static Attempt SeedAttempt(
        AttemptDbContext db,
        Guid examId,
        IEnumerable<(Guid qid, Guid sectionId, string slug, string learnerJson)> answers,
        PaperJson paper)
    {
        var attemptId = Guid.NewGuid();
        var paperJson = JsonSerializer.Serialize(paper,
            new JsonSerializerOptions(JsonSerializerDefaults.Web));
        var attempt = new Attempt
        {
            Id = attemptId,
            UserId = Guid.Parse(TestUserId),
            ExamId = examId,
            Status = "in_progress",
            StartedAt = DateTime.UtcNow,
            PaperJson = JsonDocument.Parse(paperJson),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
        db.Attempts.Add(attempt);
        foreach (var (qid, sectionId, _, learnerJson) in answers)
        {
            db.AttemptAnswers.Add(new AttemptAnswer
            {
                AttemptId = attemptId,
                SectionId = sectionId,
                QuestionId = qid,
                AnswerJson = JsonDocument.Parse(learnerJson),
                AnsweredAt = DateTime.UtcNow,
            });
        }
        db.SaveChanges();
        return attempt;
    }

    private static PaperJson BuildPaper(
        Guid examId,
        IEnumerable<(Guid sectionId, Guid qid, string slug)> questions)
    {
        var grouped = questions
            .GroupBy(q => q.sectionId)
            .Select(g => new PaperSection(
                Id: g.Key,
                Idx: 0,
                Title: "Section 1",
                Skill: null,
                InstructionsMd: null,
                PassageMd: null,
                AudioUrl: null,
                TranscriptMd: null,
                QuestionGroups: Array.Empty<PaperQuestionGroup>(),
                Questions: g.Select((qq, i) => new PaperQuestion(
                    Id: qq.qid,
                    Idx: i,
                    Type: qq.slug,
                    Skill: "READING",
                    SectionId: g.Key,
                    Payload: JsonDocument.Parse("{}").RootElement,
                    CorrectAnswer: null,
                    Rubric: null)).ToArray()))
            .ToArray();
        return new PaperJson(
            Id: examId,
            Slug: "fixture",
            Title: "AttemptFlow fixture",
            DescriptionMd: null,
            Category: "READING",
            Level: "B1",
            DurationMin: 60,
            ImageUrl: null,
            Skill: "READING",
            Sections: grouped);
    }

    [Fact]
    public async Task SubmitAsync_grades_MULTIPLE_CHOICE_SINGLE_correct_pick_and_publishes()
    {
        // Arrange
        var (db, graders, reader) = BuildCore();
        var sectionId = Guid.NewGuid();
        var qid = Guid.NewGuid();
        var examId = Guid.NewGuid();
        var paper = BuildPaper(examId, new[] { (sectionId, qid, "MULTIPLE_CHOICE_SINGLE") });
        var attempt = SeedAttempt(db, examId,
            new[] { (qid, sectionId, "MULTIPLE_CHOICE_SINGLE", """{"selectedOptionId":"opt_2"}""") },
            paper);

        var examGw = new Mock<IExamGateway>();
        examGw.Setup(g => g.GetCorrectAnswersAsync(examId, true, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new Dictionary<Guid, string>
            {
                [qid] = """{"correctOptionId":"opt_2"}""",
            });
        var bus = new Mock<IPublishEndpoint>();
        var flow = BuildFlow(db, graders, reader, examGw, bus);

        // Act
        var result = await flow.SubmitAsync(attempt.Id, CancellationToken.None);

        // Assert — graded count, persisted score, persisted awarded-points
        Assert.Equal(1, result.GradedCount);
        var reloaded = await db.Attempts.Include(a => a.Answers).FirstAsync(a => a.Id == attempt.Id);
        Assert.Equal("graded", reloaded.Status);
        Assert.Equal(1.00m, reloaded.RawScore);
        Assert.Equal(1.00m, reloaded.ScaledScore);
        var row = Assert.Single(reloaded.Answers);
        Assert.Equal(1.00m, row.AwardedPoints);
        Assert.True(row.IsCorrect);
        Assert.NotNull(reloaded.SubmittedAt);
        Assert.NotNull(reloaded.GradedAt);
        bus.Verify(b => b.Publish(It.IsAny<object>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Theory]
    // 1. MULTIPLE_CHOICE_SINGLE — full-credit match on selectedOptionId.
    [InlineData("MULTIPLE_CHOICE_SINGLE",
        """{"correctOptionId":"opt_2"}""",
        """{"selectedOptionId":"opt_2"}""", 1.00, true)]
    // 2. TRUE_FALSE_NOT_GIVEN — boolean match in the answer envelope.
    [InlineData("TRUE_FALSE_NOT_GIVEN",
        """{"correctAnswer":true}""",
        """{"answer":true}""", 1.00, true)]
    // 3. SHORT_ANSWER — text answer accepted against the normalised accept list.
    [InlineData("SHORT_ANSWER",
        """{"acceptedAnswers":["Sydney"]}""",
        """{"text":"Sydney"}""", 1.00, true)]
    // 4. SUMMARY_COMPLETION — partial credit when one of two gaps matches.
    [InlineData("SUMMARY_COMPLETION",
        """{"answers":{"q1":["plants"],"q2":["water"]}}""",
        """{"answers":{"q1":["plants"],"q2":["rocks"]}}""", 0.50, false)]
    // 5. NOTE_COMPLETION — completion-style family, full credit.
    [InlineData("NOTE_COMPLETION",
        """{"answers":{"n1":["diagram"],"n2":["flow"]}}""",
        """{"answers":{"n1":["diagram"],"n2":["flow"]}}""", 1.00, true)]
    public async Task SubmitAsync_grades_five_representative_slugs(
        string slug, string correctJson, string learnerJson, decimal expectedScore, bool fullyCorrect)
    {
        // Arrange
        var (db, graders, reader) = BuildCore();
        var sectionId = Guid.NewGuid();
        var qid = Guid.NewGuid();
        var examId = Guid.NewGuid();
        var paper = BuildPaper(examId, new[] { (sectionId, qid, slug) });
        var attempt = SeedAttempt(db, examId,
            new[] { (qid, sectionId, slug, learnerJson) },
            paper);

        var examGw = new Mock<IExamGateway>();
        examGw.Setup(g => g.GetCorrectAnswersAsync(examId, true, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new Dictionary<Guid, string>
            {
                [qid] = correctJson,
            });
        var bus = new Mock<IPublishEndpoint>();
        var flow = BuildFlow(db, graders, reader, examGw, bus);

        // Act
        var result = await flow.SubmitAsync(attempt.Id, CancellationToken.None);

        // Assert — observable contract: graded count, status, score, IsCorrect
        Assert.Equal(1, result.GradedCount);
        var reloaded = await db.Attempts.Include(a => a.Answers).FirstAsync(a => a.Id == attempt.Id);
        Assert.Equal("graded", reloaded.Status);
        Assert.Equal(expectedScore, reloaded.RawScore);
        Assert.Equal(expectedScore, reloaded.ScaledScore);
        var row = Assert.Single(reloaded.Answers);
        Assert.Equal(expectedScore, row.AwardedPoints);
        Assert.Equal(fullyCorrect, row.IsCorrect);
        Assert.NotNull(reloaded.GradedAt);
        bus.Verify(b => b.Publish(It.IsAny<object>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task SubmitAsync_attempt_not_found_throws_InvalidOperationException()
    {
        // Arrange — no seeded attempt; flow must surface the missing-row case
        // rather than silently returning an empty result.
        var (db, graders, reader) = BuildCore();
        var examGw = new Mock<IExamGateway>();
        var bus = new Mock<IPublishEndpoint>();
        var flow = BuildFlow(db, graders, reader, examGw, bus);

        // Act + Assert — EF Core throws InvalidOperationException when FirstAsync misses.
        await Assert.ThrowsAsync<InvalidOperationException>(
            () => flow.SubmitAsync(Guid.NewGuid(), CancellationToken.None));
        examGw.Verify(g => g.GetCorrectAnswersAsync(It.IsAny<Guid>(), It.IsAny<bool>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task SubmitAsync_empty_correct_map_results_in_zero_score()
    {
        // Arrange — paper has one question, learner answered it, but the
        // gateway returns no correct answers (e.g. showAnswers=false at
        // runtime). Grader must still record awarded=0 and not crash.
        var (db, graders, reader) = BuildCore();
        var sectionId = Guid.NewGuid();
        var qid = Guid.NewGuid();
        var examId = Guid.NewGuid();
        var paper = BuildPaper(examId, new[] { (sectionId, qid, "MULTIPLE_CHOICE_SINGLE") });
        var attempt = SeedAttempt(db, examId,
            new[] { (qid, sectionId, "MULTIPLE_CHOICE_SINGLE", """{"selectedOptionId":"opt_2"}""") },
            paper);

        var examGw = new Mock<IExamGateway>();
        examGw.Setup(g => g.GetCorrectAnswersAsync(examId, true, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new Dictionary<Guid, string>());
        var bus = new Mock<IPublishEndpoint>();
        var flow = BuildFlow(db, graders, reader, examGw, bus);

        // Act
        var result = await flow.SubmitAsync(attempt.Id, CancellationToken.None);

        // Assert — status flipped to graded even with no key, RawScore = 0
        Assert.Equal(1, result.GradedCount);
        var reloaded = await db.Attempts.Include(a => a.Answers).FirstAsync(a => a.Id == attempt.Id);
        Assert.Equal("graded", reloaded.Status);
        Assert.Equal(0m, reloaded.RawScore);
    }
}