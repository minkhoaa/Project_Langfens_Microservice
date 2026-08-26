using System.Text.RegularExpressions;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>SHORT_ANSWER</c>. The learner wire (and the correct wire)
/// both serialize to <see cref="ShortAnswerAnswer"/>. Awarding logic:
/// <list type="bullet">
///   <item>For each correct entry in <c>acceptedTexts</c>, normalize it and
///         compare to the normalized learner text (ordinal equality).</item>
///   <item>For each pattern in <c>acceptedRegexes</c>, run a case-insensitive,
///         culture-invariant regex match against the raw learner text.</item>
/// </list>
/// Empty/missing learner text yields 0 points with a <c>"empty answer"</c>
/// failure reason. Malformed regex patterns are silently skipped so a single
/// broken pattern cannot fail every learner.
/// </summary>
public sealed class ShortAnswerGrader(ITextNormalizer normalizer) : IGrader
{
    public string Slug => "SHORT_ANSWER";

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        var correctAns = (ShortAnswerAnswer)correct.TypedRecord;

        // The learner serializes their typed text into `acceptedTexts`
        // (same record for learner + correct). A learner submits exactly one entry.
        var learnerTexts = ((ShortAnswerAnswer)learner.TypedRecord).AcceptedTexts ?? Array.Empty<string>();
        var learnerRaw = learnerTexts.FirstOrDefault()?.Trim() ?? string.Empty;
        if (learnerRaw.Length == 0)
            return new GradeResult(0m, false, FailureReason: "empty answer");

        var learnerNorm = normalizer.Normalize(learnerRaw, norm);

        // 1. Exact-text equality against each accepted literal.
        foreach (var accepted in correctAns.AcceptedTexts ?? Array.Empty<string>())
        {
            if (string.Equals(normalizer.Normalize(accepted, norm), learnerNorm, StringComparison.Ordinal))
                return new GradeResult(1m, true);
        }

        // 2. Regex match (case-insensitive, culture-invariant).
        //    Wrap fully-anchored patterns to prevent accidental substring matches.
        var patterns = correctAns.AcceptedRegexes;
        if (patterns is null) patterns = Array.Empty<string>();
        foreach (var pattern in patterns)
        {
            if (string.IsNullOrWhiteSpace(pattern)) continue;
            var anchored = pattern.StartsWith('^') || pattern.EndsWith('$') ? pattern : $"^{pattern}$";
            try
            {
                if (Regex.IsMatch(learnerRaw, anchored, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
                    return new GradeResult(1m, true);
            }
            catch (ArgumentException)
            {
                // Malformed pattern — skip rather than abort the whole grader.
            }
        }

        return new GradeResult(0m, false, FailureReason: "no accepted match");
    }
}
