using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace attempt_service.Features.Helpers.Listening;

public interface IListeningGrader
{
    /// <summary>
    /// Returns the raw JSON envelope string, or null on failure. The
    /// orchestrator (or caller) deserializes the string into the local
    /// <c>RagFeedbackEnvelopeDto</c>.
    /// </summary>
    Task<string?> AugmentAsync(
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

public sealed class ListeningGrader : IListeningGrader
{
    private readonly IListeningExplainerClient _client;
    private readonly ILogger<ListeningGrader> _logger;

    public ListeningGrader(IListeningExplainerClient client, ILogger<ListeningGrader> logger)
    {
        _client = client;
        _logger = logger;
    }

    public async Task<string?> AugmentAsync(
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
        try
        {
            return await _client.ExplainAsync(
                itemId, transcript, question, questionType, options,
                userAnswer, correctAnswer, section, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "ListeningGrader.AugmentAsync failed for {ItemId}", itemId);
            return null;
        }
    }
}
