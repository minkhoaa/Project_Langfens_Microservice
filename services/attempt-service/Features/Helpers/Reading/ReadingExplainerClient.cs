using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace attempt_service.Features.Helpers.Reading;

public interface IReadingExplainerClient
{
    /// <summary>
    /// Returns the raw JSON envelope string from the ai-service, or null on
    /// transport / non-2xx failure. The orchestrator deserializes the string
    /// into the local <c>RagFeedbackEnvelopeDto</c>.
    /// </summary>
    Task<string?> ExplainAsync(
        string itemId,
        string passageText,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        CancellationToken ct = default);
}

public sealed class ReadingExplainerClient : IReadingExplainerClient
{
    private readonly HttpClient _http;
    private readonly ILogger<ReadingExplainerClient> _logger;

    public ReadingExplainerClient(HttpClient http, ILogger<ReadingExplainerClient> logger)
    {
        _http = http;
        _logger = logger;
    }

    public async Task<string?> ExplainAsync(
        string itemId,
        string passageText,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        CancellationToken ct = default)
    {
        var payload = new
        {
            item_id = itemId,
            passage_text = passageText,
            question,
            question_type = questionType,
            options,
            user_answer = userAnswer,
            correct_answer = correctAnswer,
        };
        try
        {
            using var resp = await _http.PostAsJsonAsync("/api/v1/reading/explain-item", payload, ct);
            if (!resp.IsSuccessStatusCode)
            {
                var body = await resp.Content.ReadAsStringAsync(ct);
                _logger.LogError(
                    "Reading explainer returned {Status} for item {ItemId}: {Body}. BaseAddress={BaseAddress}",
                    (int)resp.StatusCode, itemId, body, _http.BaseAddress);
                return null;
            }
            return await resp.Content.ReadAsStringAsync(ct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Reading explainer call failed for item {ItemId}. BaseAddress={BaseAddress}. " +
                "If this is a connection error, ensure ai-service is running and AI_SERVICE_URL points to it.",
                itemId, _http.BaseAddress);
            return null;
        }
    }
}
