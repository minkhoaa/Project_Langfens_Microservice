using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

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
