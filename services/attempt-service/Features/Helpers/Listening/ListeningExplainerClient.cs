using System.Collections.Generic;
using System.Net.Http.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace attempt_service.Features.Helpers.Listening;

public interface IListeningExplainerClient
{
    /// <summary>
    /// Returns the raw JSON envelope string from the ai-service, or null on
    /// transport / non-2xx failure. The orchestrator deserializes the string
    /// into the local <c>RagFeedbackEnvelopeDto</c>.
    /// </summary>
    Task<string?> ExplainAsync(
        string itemId,
        string transcript,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        int section,
        CancellationToken ct = default);
}

public sealed class ListeningExplainerClient : IListeningExplainerClient
{
    private readonly HttpClient _http;
    private readonly ILogger<ListeningExplainerClient> _logger;

    public ListeningExplainerClient(HttpClient http, ILogger<ListeningExplainerClient> logger)
    {
        _http = http;
        _logger = logger;
    }

    public async Task<string?> ExplainAsync(
        string itemId,
        string transcript,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        int section,
        CancellationToken ct = default)
    {
        var payload = new
        {
            item_id = itemId,
            transcript,
            question,
            question_type = questionType,
            options,
            user_answer = userAnswer,
            correct_answer = correctAnswer,
            section,
        };
        try
        {
            using var resp = await _http.PostAsJsonAsync("/api/v1/listening/explain-item", payload, ct);
            resp.EnsureSuccessStatusCode();
            return await resp.Content.ReadAsStringAsync(ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Listening explainer call failed for item {ItemId}", itemId);
            return null;
        }
    }
}
