using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Shared.PublicContracts.Contracts.Ai;

namespace attempt_service.Features.Helpers.Listening;

public interface IListeningGrader
{
    Task<RagFeedbackEnvelope?> AugmentAsync(
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

    public async Task<RagFeedbackEnvelope?> AugmentAsync(
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
