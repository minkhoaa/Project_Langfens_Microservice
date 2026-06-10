using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace attempt_service.Features.Helpers.Reading;

public interface IReadingGrader
{
    /// <summary>
    /// Returns the raw JSON envelope string, or null on failure. The
    /// orchestrator (or caller) deserializes the string into the local
    /// <c>RagFeedbackEnvelopeDto</c>.
    /// </summary>
    Task<string?> AugmentAsync(
        string itemId,
        string passageText,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        CancellationToken ct = default);
}

public sealed class ReadingGrader : IReadingGrader
{
    private readonly IReadingExplainerClient _client;
    private readonly ILogger<ReadingGrader> _logger;

    public ReadingGrader(IReadingExplainerClient client, ILogger<ReadingGrader> logger)
    {
        _client = client;
        _logger = logger;
    }

    public async Task<string?> AugmentAsync(
        string itemId,
        string passageText,
        string question,
        string questionType,
        IReadOnlyList<string> options,
        string userAnswer,
        string correctAnswer,
        CancellationToken ct = default)
    {
        try
        {
            return await _client.ExplainAsync(
                itemId, passageText, question, questionType, options,
                userAnswer, correctAnswer, ct);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "ReadingGrader.AugmentAsync failed for {ItemId}", itemId);
            return null;
        }
    }
}
