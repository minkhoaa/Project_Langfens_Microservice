using System.Net;
using System.Text;
using System.Text.Json;
using exam_service.Features.ReadingPaper;
using exam_service.Features.ReadingPaper.Contracts;
using Xunit;

namespace exam_service.Tests;

public class ReadingPaperChunkStreamTests
{
    private sealed class MockHttpHandler(string responseBody, HttpStatusCode statusCode = HttpStatusCode.OK) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var content = new StringContent(responseBody, Encoding.UTF8, "application/json");
            var response = new HttpResponseMessage(statusCode) { Content = content };
            return Task.FromResult(response);
        }
    }

    [Fact]
    public async Task ExecutePipelineAsync_DeserializesPipelineResult_OnSuccess()
    {
        var expected = new PipelineResult(
            RunId: "run_test_01",
            Status: "ACCEPTED",
            Sections: Array.Empty<ArtifactEnvelope>(),
            ExamId: Guid.NewGuid()
        );
        var json = JsonSerializer.Serialize(expected, ReadingPaperRules.Json);
        var http = new HttpClient(new MockHttpHandler(json)) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var request = new PipelineRequest(
            RunId: "run_test_01",
            JobId: Guid.NewGuid(),
            Epoch: 1,
            LeaseOwner: Guid.NewGuid(),
            Topic: "Climate Science",
            Sources: new List<SourceInput> { new(1, "PMC123", "Title", "https://url", "CC-BY") },
            SectionIndices: new List<int> { 1 },
            Parallel: false,
            Policy: PinnedExecutionPolicy.CreateDefault("minimax")
        );

        var result = await client.ExecutePipelineAsync(request, CancellationToken.None);
        Assert.NotNull(result);
        Assert.Equal("ACCEPTED", result.Status);
        Assert.Equal("run_test_01", result.RunId);
        Assert.NotNull(result.ExamId);
    }

    [Fact]
    public async Task ExecutePipelineAsync_ThrowsReadingSourceUnavailableException_On422()
    {
        var errorJson = "{\"detail\": \"Source content must contain at least 50 characters\"}";
        var http = new HttpClient(new MockHttpHandler(errorJson, HttpStatusCode.UnprocessableEntity)) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var request = new PipelineRequest(
            RunId: "run_test_02",
            JobId: Guid.NewGuid(),
            Epoch: 1,
            LeaseOwner: Guid.NewGuid(),
            Topic: "Climate Science",
            Sources: new List<SourceInput> { new(1, "PMC123", "Title", "https://url", "CC-BY") },
            SectionIndices: new List<int> { 1 },
            Parallel: false,
            Policy: PinnedExecutionPolicy.CreateDefault("minimax")
        );

        var ex = await Assert.ThrowsAsync<ReadingSourceUnavailableException>(() =>
            client.ExecutePipelineAsync(request, CancellationToken.None));
        Assert.Contains("Source content must contain at least 50 characters", ex.Message);
    }

    [Fact]
    public async Task ExecutePipelineAsync_ThrowsReadingPipelineExecutionException_OnBlueprintFailure_422()
    {
        var errorJson = "{\"detail\": \"blueprint:run_d6a23408bff741a78e5dd67c94a497e3: INVALID_OUTPUT: capability failed\"}";
        var http = new HttpClient(new MockHttpHandler(errorJson, HttpStatusCode.UnprocessableEntity)) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var request = new PipelineRequest(
            RunId: "run_test_bp_fail",
            JobId: Guid.NewGuid(),
            Epoch: 1,
            LeaseOwner: Guid.NewGuid(),
            Topic: "Paleontology",
            Sources: new List<SourceInput> { new(1, "PMC123", "Title", "https://url", "CC-BY") },
            SectionIndices: new List<int> { 1 },
            Parallel: false,
            Policy: PinnedExecutionPolicy.CreateDefault("minimax")
        );

        var ex = await Assert.ThrowsAsync<ReadingPipelineExecutionException>(() =>
            client.ExecutePipelineAsync(request, CancellationToken.None));
        Assert.Contains("blueprint:run_d6a2", ex.Message);
        Assert.IsNotType<ReadingSourceUnavailableException>(ex);
    }

    [Fact]
    public async Task ExecutePipelineAsync_ThrowsHttpRequestException_On502()
    {
        var errorJson = "{\"detail\": \"Provider gateway failed\"}";
        var http = new HttpClient(new MockHttpHandler(errorJson, HttpStatusCode.BadGateway)) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var request = new PipelineRequest(
            RunId: "run_test_03",
            JobId: Guid.NewGuid(),
            Epoch: 1,
            LeaseOwner: Guid.NewGuid(),
            Topic: "Climate Science",
            Sources: new List<SourceInput> { new(1, "PMC123", "Title", "https://url", "CC-BY") },
            SectionIndices: new List<int> { 1 },
            Parallel: false,
            Policy: PinnedExecutionPolicy.CreateDefault("minimax")
        );

        var ex = await Assert.ThrowsAsync<HttpRequestException>(() =>
            client.ExecutePipelineAsync(request, CancellationToken.None));
        Assert.Contains("502", ex.Message);
    }
    [Fact]
    public void EventEnvelope_DeserializesRichV2TaxonomyAndPayloads()
    {
        var json = """
        {
            "eventId": "evt_abc12345",
            "sequence": 42,
            "timestamp": "2026-10-08T12:00:00Z",
            "runId": "run_999",
            "eventType": "RUN_COMPLETED",
            "schemaVersion": "2.0.0",
            "engineVersion": "2.0.0",
            "payload": {
                "status": "COMPLETED",
                "runId": "run_999",
                "finalScore": 8.5
            }
        }
        """;

        var envelope = JsonSerializer.Deserialize<EventEnvelope>(json);
        Assert.NotNull(envelope);
        Assert.Equal("evt_abc12345", envelope.EventId);
        Assert.Equal(42, envelope.Sequence);
        Assert.Equal(EventType.RUN_COMPLETED, envelope.EventType);
        Assert.Equal("2.0.0", envelope.SchemaVersion);
        Assert.Equal("2.0.0", envelope.EngineVersion);
        Assert.Equal("COMPLETED", envelope.Payload.GetProperty("status").GetString());
        Assert.Equal(8.5, envelope.Payload.GetProperty("finalScore").GetDouble());
    }
}
