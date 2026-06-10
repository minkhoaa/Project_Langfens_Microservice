using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using attempt_service.Features.Helpers;
using attempt_service.Features.Helpers.Listening;
using attempt_service.Features.Helpers.RagExplainer;
using attempt_service.Features.Helpers.Reading;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace attempt_service.Tests.Helpers.RagExplainer;

public class SkillRagExplainerTests
{
    private static QMeta MakeMeta(string type, params (Guid id, string content)[] opts) =>
        new(Guid.NewGuid(), type, opts.ToHashSet());

    private static QuestionKey MakeKey(params (Guid id, string content)[] correct) =>
        new(Guid.NewGuid(), "MCQ_SINGLE", 1m, correct.ToHashSet());

    private static (string responseJson, MockHandler handler) BuildHandler(string domain)
    {
        var json = $$"""
        {
          "item_id": "test",
          "domain": "{{domain}}",
          "overall_band": 6.5,
          "criteria": [{"name":"comprehension","band":6.5,"comment":"x","evidence_ids":[]}],
          "evidence": [],
          "suggestions": [{"text":"tip","target":"comprehension"}]
        }
        """;
        return (json, new MockHandler(json));
    }

    [Fact]
    public async Task Reading_skill_calls_reading_endpoint_and_returns_envelope()
    {
        var (json, handler) = BuildHandler("reading");
        var http = new HttpClient(handler) { BaseAddress = new System.Uri("http://ai/") };
        var explainer = new SkillRagExplainer(
            new ReadingExplainerClient(http, NullLogger<ReadingExplainerClient>.Instance),
            new ListeningExplainerClient(http, NullLogger<ListeningExplainerClient>.Instance),
            NullLogger<SkillRagExplainer>.Instance);

        var meta = MakeMeta("MCQ_SINGLE",
            (Guid.NewGuid(), "A) 7am"),
            (Guid.NewGuid(), "B) 9am"));
        var key = MakeKey((meta.OptionIds.First().id, "B) 9am"));

        var env = await explainer.ExplainAsync(
            skill: "READING",
            sectionId: Guid.NewGuid(),
            questionId: Guid.NewGuid(),
            questionType: "MCQ_SINGLE",
            passageOrTranscript: "The library opens at nine.",
            options: meta.OptionIds.Select(x => x.content).ToList(),
            userAnswerText: "A) 7am",
            correctAnswerText: "B) 9am",
            section: 0,
            ct: CancellationToken.None);

        Assert.NotNull(env);
        Assert.Equal("reading", env!.Domain);
        Assert.Equal(6.5, env.OverallBand);
        Assert.Equal("/api/v1/reading/explain-item", handler.LastPath);
    }

    [Fact]
    public async Task Listening_skill_calls_listening_endpoint_with_section()
    {
        var (json, handler) = BuildHandler("listening");
        var http = new HttpClient(handler) { BaseAddress = new System.Uri("http://ai/") };
        var explainer = new SkillRagExplainer(
            new ReadingExplainerClient(http, NullLogger<ReadingExplainerClient>.Instance),
            new ListeningExplainerClient(http, NullLogger<ListeningExplainerClient>.Instance),
            NullLogger<SkillRagExplainer>.Instance);

        var env = await explainer.ExplainAsync(
            skill: "LISTENING",
            sectionId: Guid.NewGuid(),
            questionId: Guid.NewGuid(),
            questionType: "MCQ_SINGLE",
            passageOrTranscript: "Librarian: closes at six.",
            options: new System.Collections.Generic.List<string> { "A) 5pm", "B) 6pm" },
            userAnswerText: "A) 5pm",
            correctAnswerText: "B) 6pm",
            section: 1,
            ct: CancellationToken.None);

        Assert.NotNull(env);
        Assert.Equal("listening", env!.Domain);
        Assert.Equal("/api/v1/listening/explain-item", handler.LastPath);
    }

    [Fact]
    public async Task Non_reading_or_listening_skill_returns_null()
    {
        var (json, handler) = BuildHandler("writing");
        var http = new HttpClient(handler) { BaseAddress = new System.Uri("http://ai/") };
        var explainer = new SkillRagExplainer(
            new ReadingExplainerClient(http, NullLogger<ReadingExplainerClient>.Instance),
            new ListeningExplainerClient(http, NullLogger<ListeningExplainerClient>.Instance),
            NullLogger<SkillRagExplainer>.Instance);

        var env = await explainer.ExplainAsync(
            skill: "WRITING",
            sectionId: Guid.NewGuid(),
            questionId: Guid.NewGuid(),
            questionType: "TASK_2",
            passageOrTranscript: "...",
            options: new System.Collections.Generic.List<string>(),
            userAnswerText: "x",
            correctAnswerText: "y",
            section: 0,
            ct: CancellationToken.None);

        Assert.Null(env);
        Assert.Equal(0, handler.CallCount);
    }

    [Fact]
    public async Task Empty_passage_returns_null_without_calling_endpoint()
    {
        var (json, handler) = BuildHandler("reading");
        var http = new HttpClient(handler) { BaseAddress = new System.Uri("http://ai/") };
        var explainer = new SkillRagExplainer(
            new ReadingExplainerClient(http, NullLogger<ReadingExplainerClient>.Instance),
            new ListeningExplainerClient(http, NullLogger<ListeningExplainerClient>.Instance),
            NullLogger<SkillRagExplainer>.Instance);

        var env = await explainer.ExplainAsync(
            skill: "READING",
            sectionId: Guid.NewGuid(),
            questionId: Guid.NewGuid(),
            questionType: "MCQ_SINGLE",
            passageOrTranscript: "",
            options: new System.Collections.Generic.List<string> { "A", "B" },
            userAnswerText: "A",
            correctAnswerText: "B",
            section: 0,
            ct: CancellationToken.None);

        Assert.Null(env);
        Assert.Equal(0, handler.CallCount);
    }

    [Fact]
    public async Task Http_failure_returns_null_gracefully()
    {
        var handler = new MockHandler("") { ForceFail = true };
        var http = new HttpClient(handler) { BaseAddress = new System.Uri("http://ai/") };
        var explainer = new SkillRagExplainer(
            new ReadingExplainerClient(http, NullLogger<ReadingExplainerClient>.Instance),
            new ListeningExplainerClient(http, NullLogger<ListeningExplainerClient>.Instance),
            NullLogger<SkillRagExplainer>.Instance);

        var env = await explainer.ExplainAsync(
            skill: "READING",
            sectionId: Guid.NewGuid(),
            questionId: Guid.NewGuid(),
            questionType: "MCQ_SINGLE",
            passageOrTranscript: "passage",
            options: new System.Collections.Generic.List<string> { "A", "B" },
            userAnswerText: "A",
            correctAnswerText: "B",
            section: 0,
            ct: CancellationToken.None);

        Assert.Null(env);
    }

    private sealed class MockHandler : HttpMessageHandler
    {
        private readonly string _body;
        public bool ForceFail { get; init; }
        public string? LastPath { get; private set; }
        public int CallCount { get; private set; }

        public MockHandler(string body) { _body = body; }

        protected override async Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request, CancellationToken ct)
        {
            CallCount++;
            LastPath = request.RequestUri?.AbsolutePath;
            if (ForceFail)
            {
                throw new HttpRequestException("simulated network failure");
            }
            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(_body, Encoding.UTF8, "application/json"),
            };
        }
    }
}
