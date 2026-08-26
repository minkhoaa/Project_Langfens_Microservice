namespace attempt_service.Features.Helpers;

/// <summary>
/// Scoring mode shared across the 5 matching question types. All five answer records
/// expose a <c>Scoring</c> enum with the same wire values
/// (<c>all-or-nothing</c> / <c>proportional</c> / <c>afi</c> / <c>rubric</c>) even
/// though NSwag emits one C# enum per answer type. Graders map their enum onto this
/// shared mode so the helper can stay generic over the pair shape.
/// </summary>
public enum MatchingScoringMode
{
    AllOrNothing,
    Proportional,
    Afi,
    Rubric,
}

/// <summary>
/// Shared scoring for the 5 matching question types
/// (<c>MATCHING_HEADING</c>, <c>MATCHING_INFORMATION</c>, <c>MATCHING_FEATURES</c>,
/// <c>MATCHING_ENDINGS</c>, <c>CLASSIFICATION</c>). All five share the same wire shape:
/// correct answer is <c>ICollection&lt;Pairs&gt;</c> of <c>(leftId, rightId)</c> pairs;
/// learner answer is a flat <c>Dictionary&lt;string, string&gt;</c> (leftId → rightId).
/// <para>
/// The helper builds a correct map keyed by left-id, compares learner picks, then applies
/// the supplied <see cref="MatchingScoringMode"/>. <c>Rubric</c> is human-graded and is
/// flagged for manual review here.
/// </para>
/// <para>
/// <b>Proportional</b> = raw <c>matched / total</c> (no negative marking): each left-id
/// maps to exactly one right-id, so over-selection is impossible and there is nothing
/// to penalise. This differs from <c>MultipleChoiceMultipleGrader</c>, which uses
/// negative marking for over-selection on multi-select questions.
/// </para>
/// </summary>
public static class MatchingScoring
{
    /// <summary>
    /// Score a matching-style answer against the correct pairs.
    /// </summary>
    /// <param name="leftId">Selector for the left-id field on the pair (e.g. <c>p =&gt; p.ParagraphId</c>).</param>
    /// <param name="rightId">Selector for the right-id field on the pair (e.g. <c>p =&gt; p.HeadingId</c>).</param>
    /// <param name="learnerAnswers">Learner map (leftId → rightId). Null treated as empty.</param>
    /// <param name="correctPairs">Correct pairs from the typed answer.</param>
    /// <param name="mode">Scoring mode derived from the answer's Scoring enum.</param>
    public static GradeResult Score<TPair>(
        Func<TPair, string> leftId,
        Func<TPair, string> rightId,
        Dictionary<string, string>? learnerAnswers,
        ICollection<TPair> correctPairs,
        MatchingScoringMode mode)
        where TPair : class
    {
        if (correctPairs is null || correctPairs.Count == 0)
            return new GradeResult(0m, false, FailureReason: "no answer key");

        // Build correct map keyed by left-id, count per-left right picks (typically 1).
        var correctMap = new Dictionary<string, string>(correctPairs.Count, StringComparer.Ordinal);
        foreach (var p in correctPairs)
        {
            var l = leftId(p);
            if (string.IsNullOrEmpty(l)) continue;
            correctMap[l] = rightId(p);
        }
        if (correctMap.Count == 0)
            return new GradeResult(0m, false, FailureReason: "no scorable pairs");

        // Count learner correctness: per left-id, does learner pick the correct right-id?
        var matched = 0;
        foreach (var (l, expectedRight) in correctMap)
        {
            if (learnerAnswers is not null && learnerAnswers.TryGetValue(l, out var userRight)
                && !string.IsNullOrEmpty(userRight)
                && string.Equals(userRight, expectedRight, StringComparison.Ordinal))
            {
                matched++;
            }
        }
        var total = correctMap.Count;

        return mode switch
        {
            MatchingScoringMode.AllOrNothing => ScoreAllOrNothing(matched, total),
            MatchingScoringMode.Proportional => ScoreProportional(matched, total),
            MatchingScoringMode.Afi => ScoreAfi(matched, total),
            MatchingScoringMode.Rubric =>
                new GradeResult(0m, false, NeedsManualReview: true, FailureReason: "rubric scoring requires manual review"),
            _ => ScoreProportional(matched, total),
        };
    }

    private static GradeResult ScoreAllOrNothing(int matched, int total)
    {
        var ok = matched == total;
        return new GradeResult(ok ? 1m : 0m, ok);
    }

    /// <summary>
    /// Raw proportional: <c>matched / total</c>. No negative marking (see class doc).
    /// </summary>
    private static GradeResult ScoreProportional(int matched, int total)
    {
        if (total == 0) return new GradeResult(0m, false);
        var awarded = (decimal)matched / total;
        return new GradeResult(awarded, awarded >= 1m);
    }

    /// <summary>
    /// Any-fully-correct-item: same as proportional for matching (single right per left).
    /// </summary>
    private static GradeResult ScoreAfi(int matched, int total)
    {
        if (total == 0) return new GradeResult(0m, false);
        var awarded = (decimal)matched / total;
        return new GradeResult(awarded, matched == total);
    }
}
