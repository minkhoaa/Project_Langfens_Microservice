namespace attempt_service.Features.Helpers;

/// <summary>
/// Shared per-gap scoring for completion-style question types
/// (<c>SUMMARY_COMPLETION</c>, <c>TABLE_COMPLETION</c>, <c>NOTE_COMPLETION</c>,
/// <c>FORM_COMPLETION</c>). All four use the same wire shape:
/// learner answer is <c>Dictionary&lt;string, ICollection&lt;string&gt;&gt;?</c>
/// (gapId → list of user strings), correct answer is the same dictionary
/// (gapId → list of accepted strings).
/// <para>
/// Per-gap rule: a learner pick matches if any normalised accepted string
/// equals any normalised user pick for that gap. A blank gap contributes 0
/// credit. Missing learner entries contribute 0 credit.
/// </para>
/// </summary>
public static class CompletionScoring
{
    public static GradeResult Score(
        ITextNormalizer normalizer,
        Dictionary<string, ICollection<string>>? learnerAnswers,
        Dictionary<string, ICollection<string>> correctAnswers,
        NormalizationConfig norm)
    {
        if (correctAnswers.Count == 0)
            return new GradeResult(0m, false, FailureReason: "no answer key");

        int total = 0, matched = 0;
        foreach (var (gapId, accepted) in correctAnswers)
        {
            if (accepted is null || accepted.Count == 0) continue;
            total++;
            ICollection<string>? userPicks = null;
            if (learnerAnswers is not null)
                learnerAnswers.TryGetValue(gapId, out userPicks);
            var userList = userPicks ?? (ICollection<string>)Array.Empty<string>();
            var got = false;
            foreach (var a in accepted)
            {
                var an = normalizer.Normalize(a, norm);
                foreach (var u in userList)
                {
                    if (normalizer.Normalize(u, norm) == an) { got = true; break; }
                }
                if (got) break;
            }
            if (got) matched++;
        }
        if (total == 0)
            return new GradeResult(0m, false, FailureReason: "no scorable gaps");
        var score = (decimal)matched / total;
        return new GradeResult(score, matched == total);
    }
}
