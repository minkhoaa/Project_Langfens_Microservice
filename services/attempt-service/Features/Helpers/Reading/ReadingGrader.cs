using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Shared.PublicContracts.Contracts.Ai;

namespace attempt_service.Features.Helpers.Reading;

public interface IReadingGrader
{
    Task<RagFeedbackEnvelope?> AugmentAsync(
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

    public async Task<RagFeedbackEnvelope?> AugmentAsync(
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
