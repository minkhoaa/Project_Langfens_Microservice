using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>SENTENCE_COMPLETION</c>. Single-gap question. The
/// <see cref="SentenceCompletionAnswer"/> correct record carries
/// <c>acceptedTexts</c> (literal strings) plus optional <c>acceptedRegexes</c>.
/// The learner submits a single <c>text</c> string; full credit iff the
/// normalised text equals any normalised literal OR matches any supplied
/// regex pattern.
/// </summary>
public sealed class SentenceCompletionGrader(ITextNormalizer normalizer) : IGrader
{
    public string Slug => "SENTENCE_COMPLETION";

    private sealed record LearnerDto(
        [property: JsonPropertyName("text")] string? Text);

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        var correctAns = (SentenceCompletionAnswer)correct.TypedRecord;

        LearnerDto? learnerAns;
        try
        {
            learnerAns = JsonSerializer.Deserialize<LearnerDto>(learner.RawJson, Opts);
        }
        catch
        {
            return new GradeResult(0m, false, FailureReason: "learner answer malformed");
        }
        var text = learnerAns?.Text;
        if (string.IsNullOrWhiteSpace(text))
            return new GradeResult(0m, false, FailureReason: "no learner text");

        var normalised = normalizer.Normalize(text, norm);

        // Literal match against any accepted text.
        foreach (var accepted in correctAns.AcceptedTexts)
        {
            if (normalizer.Normalize(accepted, norm) == normalised)
                return new GradeResult(1m, true);
        }

        // Regex match (applied to the raw text, not normalised).
        if (correctAns.AcceptedRegexes is { Count: > 0 })
        {
            foreach (var pattern in correctAns.AcceptedRegexes)
            {
                try
                {
                    if (Regex.IsMatch(text, pattern, RegexOptions.CultureInvariant))
                        return new GradeResult(1m, true);
                }
                catch (ArgumentException)
                {
                    // bad regex — skip silently
                }
            }
        }

        return new GradeResult(0m, false);
    }
}
