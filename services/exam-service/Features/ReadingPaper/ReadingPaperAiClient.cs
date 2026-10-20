using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using exam_service.Features.ReadingPaper.Contracts;
namespace exam_service.Features.ReadingPaper;

public sealed class ReadingSourceUnavailableException(string message) : Exception(message);

public sealed class ReadingPaperAiClient(HttpClient http)
{
    public async Task<ReadingSearchResult> SearchAsync(string topic, CancellationToken ct)
        => await GetAsync<ReadingSearchResult>($"api/v1/autogen/reading-paper/sources?topic={Uri.EscapeDataString(topic)}", ct);

    public async Task<ReadingSource> FetchSourceAsync(string pmcid, CancellationToken ct)
        => await PostAsync<ReadingSource>("api/v1/autogen/reading-paper/source", new { pmcid }, ct);

    public async Task<ReadingSource> IngestSourceAsync(IngestSourceRequest request, CancellationToken ct)
        => await PostAsync<ReadingSource>("api/v1/autogen/reading-paper/source/ingest", request, ct);

    public async Task<PipelineResult> ExecutePipelineAsync(PipelineRequest request, CancellationToken ct)
        => await PostAsync<PipelineResult>("api/v1/autogen/reading-paper/execute", request, ct);
    public async Task<ReadingGeneratedQuestionsResult> GenerateQuestionsAsync(
        ArtifactRef passageRef,
        ArtifactRef blueprintRef,
        IReadOnlyList<object>? slots,
        string runId,
        Guid leaseOwner,
        int epoch = 1,
        int sectionIndex = 1,
        CancellationToken ct = default)
    {
        var payload = new
        {
            passageRef,
            blueprintRef,
            slots = slots ?? Array.Empty<object>(),
            runId,
            leaseOwner,
            epoch,
            sectionIndex,
            engine = "v2"
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/questions")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        using var response = await http.SendAsync(request, ct);
        return await ReadAsync<ReadingGeneratedQuestionsResult>(response, ct);
    }
    public async Task<ReadingGeneratedSection> GenerateSectionV2Async(
        int sectionIndex,
        string title,
        ArtifactRef passageRef,
        ArtifactRef blueprintRef,
        IReadOnlyList<ArtifactRef> questionRefs,
        string runId,
        Guid leaseOwner,
        int epoch = 1,
        CancellationToken ct = default)
    {
        var payload = new
        {
            sectionIndex,
            title,
            passageRef,
            blueprintRef,
            questionRefs,
            runId,
            leaseOwner,
            epoch,
            engine = "v2"
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/section-v2")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        using var response = await http.SendAsync(request, ct);
        return await ReadAsync<ReadingGeneratedSection>(response, ct);
    }

    public async Task<JsonElement> GeneratePaperV2Async(
        ArtifactRef blueprintRef,
        IReadOnlyList<ArtifactRef> sectionRefs,
        string runId,
        Guid leaseOwner,
        int epoch = 1,
        string title = "IELTS Academic Reading Paper",
        string? paperId = null,
        string? parentOperationId = null,
        CancellationToken ct = default)
    {
        var payload = new
        {
            blueprintRef,
            sectionRefs,
            runId,
            leaseOwner,
            epoch,
            title,
            paperId,
            parentOperationId,
            engine = "v2"
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/paper-v2")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        using var response = await http.SendAsync(request, ct);
        return await ReadAsync<JsonElement>(response, ct);
    }

    public async Task<JsonElement> EvaluatePaperAsync(
        ArtifactEnvelope paperEnvelope,
        string? runId = null,
        Guid? leaseOwner = null,
        int epoch = 1,
        CancellationToken ct = default)
    {
        var payload = new
        {
            paperEnvelope,
            runId,
            leaseOwner,
            epoch
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/paper-evaluate")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        using var response = await http.SendAsync(request, ct);
        return await ReadAsync<JsonElement>(response, ct);
    }

    public async Task<JsonElement> RepairPaperAsync(
        ArtifactEnvelope paperEnvelope,
        object directive,
        CancellationToken ct = default)
    {
        var payload = new
        {
            paperEnvelope,
            directive
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/paper-repair")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        using var response = await http.SendAsync(request, ct);
        return await ReadAsync<JsonElement>(response, ct);
    }


    public async Task<ReadingGeneratedSection> GenerateSectionAsync(string topic, int index, ReadingSource source,
        Func<string, string, Task>? onProgress, CancellationToken ct, string? provider = null,
        string? runId = null, int epoch = 1, Guid? leaseOwner = null, string? parentOperationId = null)
    {
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(ct);
        timeout.CancelAfter(TimeSpan.FromMinutes(45));
        var effectiveProvider = provider
            ?? source.Metadata?.GetValueOrDefault("provider")
            ?? Environment.GetEnvironmentVariable("READING_PAPER_LLM_PROVIDER")
            ?? Environment.GetEnvironmentVariable("LLM_PROVIDER")
            ?? "minimax";
        object payload = new
        {
            topic,
            index,
            source,
            provider = effectiveProvider,
            runId,
            epoch,
            leaseOwner,
            parentOperationId
        };
        using var request = new HttpRequestMessage(HttpMethod.Post, "api/v1/autogen/reading-paper/section")
        {
            Content = JsonContent.Create(payload, options: ReadingPaperRules.Json)
        };
        request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/x-ndjson"));
        using var response = await http.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, timeout.Token);
        if (!response.IsSuccessStatusCode)
            return await ReadAsync<ReadingGeneratedSection>(response, ct);

        if (!string.Equals(response.Content.Headers.ContentType?.MediaType, "application/x-ndjson", StringComparison.OrdinalIgnoreCase))
            return await response.Content.ReadFromJsonAsync<ReadingGeneratedSection>(ReadingPaperRules.Json, ct)
                   ?? throw new JsonException("AI service returned an empty response");

        using var stream = await response.Content.ReadAsStreamAsync(timeout.Token);
        using var reader = new StreamReader(stream);
        while (await reader.ReadLineAsync(timeout.Token) is { } line)
        {
            if (string.IsNullOrWhiteSpace(line)) continue;
            using var document = JsonDocument.Parse(line);
            var root = document.RootElement;
            switch (root.GetProperty("type").GetString())
            {
                case "log":
                    if (onProgress is not null)
                        await onProgress(root.TryGetProperty("level", out var level) ? level.GetString() ?? "Information" : "Information",
                            root.GetProperty("message").GetString() ?? "AI service progress");
                    break;
                case "result":
                    return root.GetProperty("section").Deserialize<ReadingGeneratedSection>(ReadingPaperRules.Json)
                           ?? throw new JsonException("AI service returned an empty generated section");
                case "error":
                    var message = root.TryGetProperty("message", out var messageNode) ? messageNode.GetString() : null;
                    var traceback = root.TryGetProperty("traceback", out var tracebackNode) ? tracebackNode.GetString() : null;
                    if (root.TryGetProperty("httpStatus", out var statusNode) && statusNode.GetInt32() == 422)
                        throw new ReadingSourceUnavailableException(string.IsNullOrWhiteSpace(traceback)
                            ? message ?? "AI source generation failed"
                            : $"{message}{Environment.NewLine}{traceback}");
                    throw new HttpRequestException(string.IsNullOrWhiteSpace(traceback)
                        ? $"AI generation failed: {message}"
                        : $"AI generation failed: {message}{Environment.NewLine}{traceback}");
                default:
                    throw new JsonException("AI service returned an unknown progress event");
            }
        }
        throw new JsonException("AI service closed the progress stream without a generated section");
    }

    private async Task<T> GetAsync<T>(string path, CancellationToken ct)
    {
        using var response = await http.GetAsync(path, ct);
        return await ReadAsync<T>(response, ct);
    }

    private async Task<T> PostAsync<T>(string path, object body, CancellationToken ct)
    {
        using var response = await http.PostAsJsonAsync(path, body, ReadingPaperRules.Json, ct);
        return await ReadAsync<T>(response, ct);
    }

    private static async Task<T> ReadAsync<T>(HttpResponseMessage response, CancellationToken ct)
    {
        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);
            var message = body.Length > 500 ? body[..500] : body;
            if (response.StatusCode == HttpStatusCode.UnprocessableEntity)
                throw new ReadingSourceUnavailableException(message);
            throw new HttpRequestException($"AI service returned {(int)response.StatusCode}: {message}");
        }
        return await response.Content.ReadFromJsonAsync<T>(ReadingPaperRules.Json, ct)
               ?? throw new JsonException("AI service returned an empty response");
    }
}

public sealed record SourceInput(
    [property: JsonPropertyName("sectionIndex")] int SectionIndex,
    [property: JsonPropertyName("pmcid")] string Pmcid,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("url")] string Url,
    [property: JsonPropertyName("license")] string License,
    [property: JsonPropertyName("content")] string? Content = null,
    [property: JsonPropertyName("doi")] string? Doi = null,
    [property: JsonPropertyName("authors")] string? Authors = null
);

public sealed record GroupPolicyConfig(
    [property: JsonPropertyName("questionType")] string QuestionType,
    [property: JsonPropertyName("count")] int Count
);

public sealed record SectionPolicyConfig(
    [property: JsonPropertyName("index")] int Index,
    [property: JsonPropertyName("startNumber")] int StartNumber,
    [property: JsonPropertyName("groups")] IReadOnlyList<GroupPolicyConfig> Groups,
    [property: JsonPropertyName("minWords")] int MinWords,
    [property: JsonPropertyName("maxWords")] int MaxWords,
    [property: JsonPropertyName("difficulty")] string Difficulty,
    [property: JsonPropertyName("editorialObjective")] string EditorialObjective
);

public sealed record PinnedExecutionPolicy(
    [property: JsonPropertyName("provider")] string Provider,
    [property: JsonPropertyName("providerCallSeconds")] double ProviderCallSeconds,
    [property: JsonPropertyName("sectionWallSeconds")] double SectionWallSeconds,
    [property: JsonPropertyName("sectionTokenCap")] int SectionTokenCap,
    [property: JsonPropertyName("runTokenCap")] int RunTokenCap,
    [property: JsonPropertyName("runWallSeconds")] double RunWallSeconds,
    [property: JsonPropertyName("maxCandidates")] int MaxCandidates,
    [property: JsonPropertyName("maxRepairs")] int MaxRepairs,
    [property: JsonPropertyName("maxEvaluationsPerArtifact")] int MaxEvaluationsPerArtifact,
    [property: JsonPropertyName("maxDependencyDepth")] int MaxDependencyDepth,
    [property: JsonPropertyName("maxRecoveryAttempts")] int MaxRecoveryAttempts,
    [property: JsonPropertyName("sourceMinWords")] int SourceMinWords,
    [property: JsonPropertyName("minVerifiedClaims")] int MinVerifiedClaims,
    [property: JsonPropertyName("paperMinWords")] int PaperMinWords,
    [property: JsonPropertyName("paperMaxWords")] int PaperMaxWords,
    [property: JsonPropertyName("requireBlindSolver")] bool RequireBlindSolver,
    [property: JsonPropertyName("sections")] IReadOnlyList<SectionPolicyConfig> Sections
)
{
    public static PinnedExecutionPolicy CreateDefault(string provider = "minimax") => new(
        Provider: provider.ToLowerInvariant(),
        ProviderCallSeconds: 180.0,
        SectionWallSeconds: 900.0,
        SectionTokenCap: 100000,
        RunTokenCap: 300000,
        RunWallSeconds: 2700.0,
        MaxCandidates: 3,
        MaxRepairs: 2,
        MaxEvaluationsPerArtifact: 8,
        MaxDependencyDepth: 3,
        MaxRecoveryAttempts: 2,
        SourceMinWords: 600,
        MinVerifiedClaims: 3,
        PaperMinWords: 2150,
        PaperMaxWords: 2750,
        RequireBlindSolver: true,
        Sections: [
            new SectionPolicyConfig(
                Index: 1,
                StartNumber: 1,
                Groups: [
                    new GroupPolicyConfig("TRUE_FALSE_NOT_GIVEN", 7),
                    new GroupPolicyConfig("SENTENCE_COMPLETION", 6)
                ],
                MinWords: 720,
                MaxWords: 915,
                Difficulty: "FOUNDATION",
                EditorialObjective: "Establish a factual baseline the later sections may safely build on."
            ),
            new SectionPolicyConfig(
                Index: 2,
                StartNumber: 14,
                Groups: [
                    new GroupPolicyConfig("MULTIPLE_CHOICE_SINGLE", 6),
                    new GroupPolicyConfig("SUMMARY_COMPLETION", 7)
                ],
                MinWords: 720,
                MaxWords: 915,
                Difficulty: "MODERATE",
                EditorialObjective: "Test paraphrase and distribution of explicitly stated scientific detail."
            ),
            new SectionPolicyConfig(
                Index: 3,
                StartNumber: 27,
                Groups: [
                    new GroupPolicyConfig("YES_NO_NOT_GIVEN", 7),
                    new GroupPolicyConfig("SHORT_ANSWER", 7)
                ],
                MinWords: 720,
                MaxWords: 915,
                Difficulty: "ADVANCED",
                EditorialObjective: "Require inference strictly licensed by the passage and claim evidence."
            )
        ]
    );

    public string ComputeHash()
    {
        var json = JsonSerializer.Serialize(this, ReadingPaperRules.Json);
        using var doc = JsonDocument.Parse(json);
        using var ms = new MemoryStream();
        using (var writer = new Utf8JsonWriter(ms, new JsonWriterOptions { Indented = false, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping }))
        {
            WriteCanonical(writer, doc.RootElement);
        }
        var bytes = SHA256.HashData(ms.ToArray());
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    private static void WriteCanonical(Utf8JsonWriter writer, JsonElement element)
    {
        switch (element.ValueKind)
        {
            case JsonValueKind.Object:
                writer.WriteStartObject();
                foreach (var prop in element.EnumerateObject().OrderBy(p => p.Name, StringComparer.Ordinal))
                {
                    writer.WritePropertyName(prop.Name);
                    WriteCanonical(writer, prop.Value);
                }
                writer.WriteEndObject();
                break;
            case JsonValueKind.Array:
                writer.WriteStartArray();
                foreach (var item in element.EnumerateArray())
                {
                    WriteCanonical(writer, item);
                }
                writer.WriteEndArray();
                break;
            default:
                element.WriteTo(writer);
                break;
        }
    }
}

public sealed record PipelineRequest(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("jobId")] Guid JobId,
    [property: JsonPropertyName("epoch")] int Epoch,
    [property: JsonPropertyName("leaseOwner")] Guid LeaseOwner,
    [property: JsonPropertyName("topic")] string Topic,
    [property: JsonPropertyName("sources")] IReadOnlyList<SourceInput> Sources,
    [property: JsonPropertyName("sectionIndices")] IReadOnlyList<int> SectionIndices,
    [property: JsonPropertyName("parallel")] bool Parallel,
    [property: JsonPropertyName("policy")] PinnedExecutionPolicy Policy,
    [property: JsonPropertyName("finalize")] bool Finalize = true
);

public sealed record PipelineResult(
    [property: JsonPropertyName("runId")] string RunId,
    [property: JsonPropertyName("status")] string Status,
    [property: JsonPropertyName("sections")] IReadOnlyList<ArtifactEnvelope> Sections,
    [property: JsonPropertyName("paper")] ArtifactEnvelope? Paper = null,
    [property: JsonPropertyName("examId")] Guid? ExamId = null,
    [property: JsonPropertyName("metrics")] Dictionary<string, object>? Metrics = null
);
