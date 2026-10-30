using System.Net.Http.Json;
using System.Text.Json;
using attempt_service.Contracts.Attempt;
using attempt_service.Domain.Entities;
using attempt_service.Features.Attempt.AttemptEndpoint;
using attempt_service.Features.Helpers;
using attempt_service.Features.Helpers.RagExplainer;
using Google.Protobuf;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using Shared.ExamDto.Contracts.Exam.Enums;
using Shared.Grpc.ExamInternal;
using Xunit;

namespace attempt_service.Tests.Helpers;

public class AttemptAnswerLifecycleTests
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task Malformed_legacy_identity_fails_closed_without_falling_back_to_private_section_questions(bool resume)
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var attempt = await fixture.Db.Attempts.SingleAsync();
        var legacy = System.Text.Json.Nodes.JsonNode.Parse(attempt.PaperJson!.RootElement.GetRawText())!;
        var section = legacy["sections"]![0]!;
        section["id"] = Guid.Empty.ToString();
        section["questions"]![0]!["explanationMd"] = "PRIVATE_LEGACY_REGRESSION_SENTINEL";
        using var corrupted = JsonDocument.Parse(legacy.ToJsonString());
        attempt.PaperJson = corrupted;
        var examId = attempt.ExamId;
        await fixture.Db.SaveChangesAsync();
        fixture.Db.ChangeTracker.Clear();

        var result = resume
            ? await fixture.Service.StartAttempt(new(examId), default)
            : await fixture.Service.GetAttemptById(fixture.AttemptId, default);

        var response = JsonSerializer.Serialize(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.DoesNotContain("PRIVATE_LEGACY_REGRESSION_SENTINEL", response);
        Assert.Equal(500, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Equal(corrupted.RootElement.GetRawText(),
            (await fixture.Db.Attempts.AsNoTracking().SingleAsync()).PaperJson!.RootElement.GetRawText());
    }

    [Fact]
    public async Task Rest_section_questions_snapshot_is_read_for_autosave_submit_restore_and_results()
    {
        await using var fixture = await AttemptAnswerFixture.CreateLegacyRest();
        var answer = new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null);

        var saved = await fixture.Service.Autosave(fixture.AttemptId, new([answer], null), default);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(saved).StatusCode);
        var resumed = await fixture.Service.GetAttemptById(fixture.AttemptId, default);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(resumed).StatusCode);
        var submitted = await fixture.Service.Submit(fixture.AttemptId, default);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(submitted).StatusCode);
        var result = await fixture.Service.GetResult(fixture.AttemptId, default);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True((await fixture.ReadAnswer()).IsCorrect);
    }

    [Theory]
    [InlineData("", "saved answer", false)]
    [InlineData(",\"textAnswer\":null", null, true)]
    [InlineData(",\"textAnswer\":\"\"", "", true)]
    [InlineData(",\"textAnswer\":\"replacement\"", "replacement", true)]
    [InlineData(",\"textAnswer\":\"saved answer\"", "saved answer", false)]
    public async Task Autosave_distinguishes_text_presence_and_preserves_omitted_selections(
        string textField, string? expectedText, bool changed)
    {
        await using var fixture = await AttemptAnswerFixture.Create();
        var json = $"{{\"questionId\":\"{fixture.QuestionId}\",\"sectionId\":\"{fixture.SectionId}\"{textField}}}";
        var answer = JsonSerializer.Deserialize<AnswerItem>(json, JsonOptions)!;

        var result = await fixture.Service.Autosave(fixture.AttemptId, new([answer], null), default);

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var saved = await fixture.ReadAnswer();
        Assert.Equal(expectedText, saved.TextAnswer);
        Assert.Equal(new[] { fixture.OptionId }, saved.SelectedOptionIds);
        Assert.Equal(changed ? (bool?)null : true, saved.IsCorrect);
        Assert.Equal(changed ? (decimal?)null : 1m, saved.AwardedPoints);
        Assert.Equal(fixture.SectionId, saved.SectionId);
    }

    [Fact]
    public async Task Existing_constructor_with_null_keeps_its_no_update_semantics()
    {
        await using var fixture = await AttemptAnswerFixture.Create();
        var answer = new AnswerItem(fixture.QuestionId, fixture.SectionId, null, null);

        await fixture.Service.Autosave(fixture.AttemptId, new([answer], null), default);

        var saved = await fixture.ReadAnswer();
        Assert.Equal("saved answer", saved.TextAnswer);
        Assert.True(saved.IsCorrect);
        Assert.Equal(1m, saved.AwardedPoints);
        var (questionId, sectionId, selections, text) = answer;
        Assert.Equal(fixture.QuestionId, questionId);
        Assert.Equal(fixture.SectionId, sectionId);
        Assert.Null(selections);
        Assert.Null(text);
    }

    [Theory]
    [InlineData(1, 1, true)]
    [InlineData(0, 0, false)]
    [InlineData(-1, 0, false)]
    public async Task Submit_grades_inline_final_answer_and_derives_section(
        int correct, int points, bool expectedCorrect)
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        List<Guid>? options = correct < 0 ? null : [correct == 1 ? fixture.OptionId : fixture.WrongOptionId];
        var result = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([new AnswerItem(fixture.QuestionId, Guid.NewGuid(), options, null)]), default);

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var saved = await fixture.ReadAnswer();
        Assert.Equal(fixture.SectionId, saved.SectionId);
        Assert.Equal(expectedCorrect, saved.IsCorrect);
        Assert.Equal(points, saved.AwardedPoints);
    }

    [Fact]
    public async Task Submit_merges_inline_values_over_existing_autosave_and_is_idempotent()
    {
        await using var fixture = await AttemptAnswerFixture.Create();
        var final = new SubmitRequest([new AnswerItem(fixture.QuestionId, fixture.SectionId,
            [fixture.WrongOptionId], null)]);

        var first = await fixture.Service.Submit(fixture.AttemptId, final, default);
        var second = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null)]), default);

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(first).StatusCode);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(second).StatusCode);
        var saved = await fixture.ReadAnswer();
        Assert.Equal(new[] { fixture.WrongOptionId }, saved.SelectedOptionIds);
        Assert.False(saved.IsCorrect);
    }

    [Fact]
    public async Task Submit_bodyless_overload_still_grades_saved_answer()
    {
        await using var fixture = await AttemptAnswerFixture.Create();
        var result = await fixture.Service.Submit(fixture.AttemptId, default);

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True((await fixture.ReadAnswer()).IsCorrect);
    }

    [Fact]
    public async Task Submit_allows_expired_bodyless_auto_finalization()
    {
        await using var fixture = await AttemptAnswerFixture.Create(expired: true);

        var result = await fixture.Service.Submit(fixture.AttemptId, default);

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True((await fixture.ReadAnswer()).IsCorrect);
    }

    [Fact]
    public async Task Submit_rejects_expired_inline_batch_without_mutation()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false, expired: true);
        var result = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null)]), default);

        Assert.Equal(409, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
        Assert.Equal("STARTED", (await fixture.Db.Attempts.SingleAsync()).Status);
    }

    [Fact]
    public async Task Submit_rejects_invalid_batch_without_partial_persistence()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var result = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([
                new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null),
                new AnswerItem(Guid.NewGuid(), fixture.SectionId, [], null)
            ]), default);

        Assert.Equal(422, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
        Assert.Equal("STARTED", (await fixture.Db.Attempts.SingleAsync()).Status);
    }

    [Fact]
    public async Task Submit_rejects_foreign_attempt_without_mutation()
    {
        await using var fixture = await AttemptAnswerFixture.Create();
        var result = await fixture.Service.Submit(Guid.NewGuid(),
            new SubmitRequest([new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null)]), default);

        Assert.Equal(404, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Single(await fixture.Db.AttemptAnswers.ToListAsync());
        Assert.Equal("STARTED", (await fixture.Db.Attempts.SingleAsync()).Status);
    }

    [Fact]
    public async Task Submit_rejects_foreign_option_without_partial_persistence()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var result = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([new AnswerItem(fixture.QuestionId, fixture.SectionId, [Guid.NewGuid()], null)]), default);

        Assert.Equal(422, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
    }

    [Fact]
    public async Task Submit_rejects_null_final_answer_without_mutation()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var request = JsonSerializer.Deserialize<SubmitRequest>("{\"answers\":[null]}", JsonOptions)!;

        var result = await fixture.Service.Submit(fixture.AttemptId, request, default);

        Assert.Equal(422, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
        Assert.Equal("STARTED", (await fixture.Db.Attempts.SingleAsync()).Status);
    }

    [Fact]
    public void AnswerItem_constructor_preserves_original_named_argument_parameter_names()
    {
        var constructor = typeof(AnswerItem).GetConstructors()
            .Single(candidate => candidate.GetParameters().Length == 4);
        Assert.Equal(
            new[] { "QuestionId", "SectionId", "SelectedOptionIds", "TextAnswer" },
            constructor.GetParameters().Select(parameter => parameter.Name));
    }

    [Fact]
    public async Task Submit_rejects_duplicate_batch_without_partial_persistence()
    {
        await using var fixture = await AttemptAnswerFixture.Create(seedAnswer: false);
        var answer = new AnswerItem(fixture.QuestionId, fixture.SectionId, [fixture.OptionId], null);
        var result = await fixture.Service.Submit(fixture.AttemptId,
            new SubmitRequest([answer, answer]), default);

        Assert.Equal(422, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await fixture.Db.AttemptAnswers.ToListAsync());
    }

    [Theory]
    [InlineData(0)]
    [InlineData(1)]
    [InlineData(2)]
    public async Task Submit_handler_binds_inline_json_and_allows_optional_body(int bodyMode)
    {
        var service = new Mock<IAttemptService>();
        SubmitRequest? captured = null;
        service.Setup(value => value.Submit(It.IsAny<Guid>(), It.IsAny<SubmitRequest?>(), It.IsAny<CancellationToken>()))
            .Callback<Guid, SubmitRequest?, CancellationToken>((_, body, _) => captured = body)
            .ReturnsAsync(Results.Ok());
        using var server = new Microsoft.AspNetCore.TestHost.TestServer(new Microsoft.AspNetCore.Hosting.WebHostBuilder()
            .ConfigureServices(services => services.AddRouting().AddSingleton(service.Object))
            .Configure(app => app.UseRouting().UseEndpoints(endpoints =>
                endpoints.MapPost("/submit/{attemptId:guid}", AttemptHandler.AttemptSubmit))));
        var client = server.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Post, $"/submit/{Guid.NewGuid()}");
        if (bodyMode == 1) request.Content = JsonContent.Create(new { answers = Array.Empty<object>() });
        if (bodyMode == 2) request.Content = JsonContent.Create(new { });

        using var response = await client.SendAsync(request);

        Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);
        service.Verify(value => value.Submit(It.IsAny<Guid>(), It.IsAny<SubmitRequest?>(),
            It.IsAny<CancellationToken>()), Times.Once);
        Assert.Equal(bodyMode != 0, captured is not null);
    }

    [Fact]
    public async Task Submit_handler_accepts_an_optional_inline_answer_body()
    {
        var handler = typeof(AttemptHandler).GetMethod(nameof(AttemptHandler.AttemptSubmit))!;
        Assert.Contains(handler.GetParameters(), parameter =>
            parameter.ParameterType.Name == "SubmitRequest" && parameter.ParameterType.IsClass);
    }

    [Fact]
    public void Presence_tracking_does_not_add_a_wire_property()
    {
        var answer = JsonSerializer.Deserialize<AnswerItem>(
            $"{{\"questionId\":\"{Guid.NewGuid()}\",\"textAnswer\":null}}", JsonOptions)!;
        var json = JsonSerializer.SerializeToElement(answer, JsonOptions);
        Assert.Equal(
            new[] { "questionId", "sectionId", "selectedOptionIds", "textAnswer" },
            json.EnumerateObject().Select(property => property.Name).OrderBy(name => name, StringComparer.Ordinal));
    }
}

// Uses the production Autosave/index/validator over a disposable InMemory store.
// External collaborators are deliberately unused; no service Program or real DB is started.
internal sealed class AttemptAnswerFixture : IAsyncDisposable
{
    public OfflineAttemptDbContext Db { get; } = new();
    public Guid UserId { get; } = Guid.NewGuid();
    public Guid AttemptId { get; } = Guid.NewGuid();
    public Guid SectionId { get; } = Guid.NewGuid();
    public Guid QuestionId { get; } = Guid.NewGuid();
    public Guid OptionId { get; } = Guid.NewGuid();
    public Guid WrongOptionId { get; } = Guid.NewGuid();
    public AttemptService Service { get; }
    public Mock<ISkillRagExplainer> Rag { get; } = new();
    private readonly JsonDocument paper;

    private AttemptAnswerFixture(bool seedAnswer, bool expired, bool legacyRest = false)
    {
        if (legacyRest)
        {
            var examId = Guid.NewGuid();
            paper = JsonDocument.Parse($"{{\"id\":\"{examId}\",\"durationMin\":60,\"sections\":[{{\"id\":\"{SectionId}\",\"idx\":1,\"title\":\"Section\",\"questions\":[{{\"id\":\"{QuestionId}\",\"idx\":1,\"type\":\"MULTIPLE_CHOICE_SINGLE\",\"skill\":\"READING\",\"promptMd\":\"Prompt\",\"options\":[{{\"id\":\"{OptionId}\",\"idx\":1,\"contentMd\":\"Correct\",\"isCorrect\":true}},{{\"id\":\"{WrongOptionId}\",\"idx\":2,\"contentMd\":\"Wrong\",\"isCorrect\":false}}]}}]}}]}}");
            Db.Attempts.Add(new Attempt { Id = AttemptId, UserId = UserId, ExamId = examId,
                StartedAt = DateTime.UtcNow.AddMinutes(-1), DurationSec = 3600, PaperJson = paper });
            SeedAnswer(seedAnswer);
            Service = CreateService();
            return;
        }
        var question = new InternalDeliveryQuestion
        {
            Id = QuestionId.ToString(), Idx = 1,
            Type = QuestionType.MultipleChoiceSingle, Skill = "READING", PromptMd = "Public question",
            Options = {
                new InternalDeliveryOption { Id = OptionId.ToString(), Idx = 1, ContentMd = "Correct option", IsCorrect = true },
                new InternalDeliveryOption { Id = WrongOptionId.ToString(), Idx = 2, ContentMd = "Wrong option", IsCorrect = false }
            }
        };
        var snapshot = new InternalDeliveryExam
        {
            Id = Guid.NewGuid().ToString(), DurationMin = 60,
            Sections = { new InternalDeliverySection
            {
                Id = SectionId.ToString(), Idx = 1,
                QuestionGroups = { new InternalDeliveryQuestionGroup
                {
                    Id = Guid.NewGuid().ToString(), Idx = 1, StartIdx = 1, EndIdx = 1, Questions = { question }
                } }
            } }
        };
        paper = JsonDocument.Parse(JsonFormatter.Default.Format(snapshot));
        Db.Attempts.Add(new Attempt
        {
            Id = AttemptId, UserId = UserId, ExamId = Guid.Parse(snapshot.Id),
            StartedAt = expired ? DateTime.UtcNow.AddHours(-2) : DateTime.UtcNow.AddMinutes(-1),
            DurationSec = 3600, PaperJson = paper
        });
        SeedAnswer(seedAnswer);
        Service = CreateService();
    }

    public static async Task<AttemptAnswerFixture> Create(bool seedAnswer = true, bool expired = false)
    {
        var fixture = new AttemptAnswerFixture(seedAnswer, expired);
        await fixture.Db.SaveChangesAsync();
        fixture.Db.ChangeTracker.Clear();
        return fixture;
    }

    public static async Task<AttemptAnswerFixture> CreateLegacyRest()
    {
        var fixture = new AttemptAnswerFixture(seedAnswer: false, expired: false, legacyRest: true);
        await fixture.Db.SaveChangesAsync();
        fixture.Db.ChangeTracker.Clear();
        return fixture;
    }

    private void SeedAnswer(bool seedAnswer)
    {
        if (seedAnswer)
            Db.AttemptAnswers.Add(new AttemptAnswer
            {
                AttemptId = AttemptId, QuestionId = QuestionId, SectionId = SectionId,
                SelectedOptionIds = [OptionId], TextAnswer = "saved answer", IsCorrect = true, AwardedPoints = 1m
            });
    }

    private AttemptService CreateService()
    {
        var user = new Mock<IUserContext>();
        user.SetupGet(value => value.UserId).Returns(UserId);
        var graderFactory = new QuestionGraderFactory([
            new SingleChoiceGraderRegistration(new SingleChoiceGrader()),
            new MultipleChoiceGraderRegistration(new MultipleChoiceGrader()),
            new CompletionGraderRegistration(new CompletionGrader()),
            new LabelGraderRegistration(new LabelGrader()),
            new MatchingHeadingGraderRegistration(new MatchingHeadingGrader()),
            new FlowChartGraderRegistration(new FlowChartGrader()),
            new ShortAnswerGraderRegistration(new ShortAnswerGrader())
        ]);
        Rag.Setup(explainer => explainer.ExplainAsync(It.IsAny<string>(), It.IsAny<Guid>(), It.IsAny<Guid>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<IReadOnlyList<string>>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync((RagFeedbackEnvelopeDto?)null);
        var publisher = new Mock<MassTransit.IPublishEndpoint>();
        return new AttemptService(Db, null!, user.Object, new AnswerKeyBuilder(new AnswerValidator()),
            new IndexBuilder(), new AnswerValidator(), null!, publisher.Object, graderFactory,
            Rag.Object, new SectionContextLookup());
    }

    public async Task<AttemptAnswer> ReadAnswer()
    {
        Db.ChangeTracker.Clear();
        return await Db.AttemptAnswers.AsNoTracking().SingleAsync(answer => answer.AttemptId == AttemptId);
    }

    public async ValueTask DisposeAsync()
    {
        await Db.DisposeAsync();
        paper.Dispose();
    }
}
