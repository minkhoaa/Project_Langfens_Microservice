using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Shared.PublicContracts.Contracts.Ai;

namespace attempt_service.Features.Helpers.Reading;

public interface IReadingExplainerClient
{
    Task<RagFeedbackEnvelope?> ExplainAsync(
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

    public async Task<RagFeedbackEnvelope?> ExplainAsync(
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
            resp.EnsureSuccessStatusCode();
            return await resp.Content.ReadFromJsonAsync<RagFeedbackEnvelope>(cancellationToken: ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Reading explainer call failed for item {ItemId}", itemId);
            return null;
        }
    }
}
