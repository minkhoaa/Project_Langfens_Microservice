using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using exam_service.Features.ReadingPaper.Contracts;
namespace exam_service.Features.ReadingPaper;

public sealed class ReadingSourceUnavailableException(string message) : Exception(message);
public sealed class ReadingPipelineExecutionException(string message) : Exception(message);

public sealed class ReadingPaperAiClient(HttpClient http)
{
    public async Task<ReadingSearchResult> SearchAsync(string topic, CancellationToken ct)
        => await GetAsync<ReadingSearchResult>($"api/v1/autogen/reading-paper/sources?topic={Uri.EscapeDataString(topic)}", ct);

    public async Task<ReadingSource> FetchSourceAsync(string pmcid, CancellationToken ct)
        => await PostAsync<ReadingSource>("api/v1/autogen/reading-paper/source", new { pmcid }, ct);

    public async Task<ReadingSource> IngestSourceAsync(IngestSourceRequest request, CancellationToken ct)
        => await PostAsync<ReadingSource>("api/v1/autogen/reading-paper/source/ingest", request, ct);

    public async Task<PipelineResult> ExecutePipelineAsync(PipelineRequest request, CancellationToken ct)
        => await PostAsync<PipelineResult>("api/v1/autogen/reading-paper/execute", request, ct, isPipeline: true);

    private async Task<T> GetAsync<T>(string path, CancellationToken ct)
    {
        using var response = await http.GetAsync(path, ct);
        return await ReadAsync<T>(response, ct, isPipeline: false);
    }

    private async Task<T> PostAsync<T>(string path, object body, CancellationToken ct, bool isPipeline = false)
    {
        using var response = await http.PostAsJsonAsync(path, body, ReadingPaperRules.Json, ct);
        return await ReadAsync<T>(response, ct, isPipeline);
    }

    private static async Task<T> ReadAsync<T>(HttpResponseMessage response, CancellationToken ct, bool isPipeline = false)
    {
        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);
            var message = body.Length > 500 ? body[..500] : body;
            if (response.StatusCode == HttpStatusCode.UnprocessableEntity)
            {
                if (isPipeline && !IsSourceAcquisitionError(message))
                    throw new ReadingPipelineExecutionException(message);
                throw new ReadingSourceUnavailableException(message);
            }
            throw new HttpRequestException($"AI service returned {(int)response.StatusCode}: {message}");
        }
        return await response.Content.ReadFromJsonAsync<T>(ReadingPaperRules.Json, ct)
               ?? throw new JsonException("AI service returned an empty response");
    }

    private static bool IsSourceAcquisitionError(string message)
    {
        if (message.Contains("Source content", StringComparison.OrdinalIgnoreCase))
            return true;
        if (message.Contains("Select one to three distinct verified sources", StringComparison.OrdinalIgnoreCase))
            return true;
        if (message.Contains("source license", StringComparison.OrdinalIgnoreCase) || message.Contains("licenseCleared", StringComparison.OrdinalIgnoreCase))
            return true;
        if (message.Contains("source:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("blueprint:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("evidence:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("passage:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("question:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("section:", StringComparison.OrdinalIgnoreCase) &&
            !message.Contains("paper:", StringComparison.OrdinalIgnoreCase))
            return true;
        return false;
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
    [property: JsonPropertyName("blueprintMode")] string BlueprintMode,
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
        BlueprintMode: "dynamic",
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
