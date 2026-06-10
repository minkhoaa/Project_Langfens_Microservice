using System.Text.Json;
using attempt_service.Features.Helpers.Listening;
using attempt_service.Features.Helpers.Reading;
using Microsoft.Extensions.Logging;

namespace attempt_service.Features.Helpers.RagExplainer;

public interface ISkillRagExplainer
{
    /// <summary>
    /// Returns a parsed envelope for a reading/listening question, or null if
    /// the skill is unsupported, the passage/transcript is missing, or the
    /// HTTP call fails. Never throws.
    /// </summary>
    Task<RagFeedbackEnvelopeDto?> ExplainAsync(
        string skill,
        Guid sectionId,
        Guid questionId,
        string questionType,
        string passageOrTranscript,
        IReadOnlyList<string> options,
        string userAnswerText,
        string correctAnswerText,
        int section,
        CancellationToken ct);
}

public sealed class SkillRagExplainer : ISkillRagExplainer
{
    private static readonly JsonSerializerOptions JsonOpts = new(JsonSerializerDefaults.Web);

    private readonly IReadingExplainerClient _reading;
    private readonly IListeningExplainerClient _listening;
    private readonly ILogger<SkillRagExplainer> _logger;

    public SkillRagExplainer(
        IReadingExplainerClient reading,
        IListeningExplainerClient listening,
        ILogger<SkillRagExplainer> logger)
    {
        _reading = reading;
        _listening = listening;
        _logger = logger;
    }

    public async Task<RagFeedbackEnvelopeDto?> ExplainAsync(
        string skill,
        Guid sectionId,
        Guid questionId,
        string questionType,
        string passageOrTranscript,
        IReadOnlyList<string> options,
        string userAnswerText,
        string correctAnswerText,
        int section,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(passageOrTranscript))
        {
            _logger.LogDebug("RAG: no passage/transcript for question {QuestionId}; skipping", questionId);
            return null;
        }

        var skillUpper = (skill ?? string.Empty).Trim().ToUpperInvariant();
        string? envelopeJson = skillUpper switch
        {
            "READING" => await SafeCallAsync(() => _reading.ExplainAsync(
                itemId: questionId.ToString(),
                passageText: passageOrTranscript,
                question: userAnswerText + " | " + correctAnswerText, // best-effort: user-facing prompt includes both
                questionType: questionType,
                options: options,
                userAnswer: userAnswerText,
                correctAnswer: correctAnswerText,
                ct: ct), questionId),
            "LISTENING" => await SafeCallAsync(() => _listening.ExplainAsync(
                itemId: questionId.ToString(),
                transcript: passageOrTranscript,
                question: userAnswerText + " | " + correctAnswerText,
                questionType: questionType,
                options: options,
                userAnswer: userAnswerText,
                correctAnswer: correctAnswerText,
                section: section,
                ct: ct), questionId),
            _ => null,
        };

        if (string.IsNullOrEmpty(envelopeJson)) return null;
        try
        {
            return JsonSerializer.Deserialize<RagFeedbackEnvelopeDto>(envelopeJson, JsonOpts);
        }
        catch (JsonException ex)
        {
            _logger.LogWarning(ex, "RAG: bad envelope JSON for question {QuestionId}", questionId);
            return null;
        }
    }

    private async Task<string?> SafeCallAsync(Func<Task<string?>> call, Guid questionId)
    {
        try
        {
            return await call();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "RAG: explainer call failed for question {QuestionId}", questionId);
            return null;
        }
    }
}
