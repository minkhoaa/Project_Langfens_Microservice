using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>FLOW_CHART_COMPLETION</c>. Correct answer carries two parts:
/// <list type="bullet">
/// <item><c>Order: ICollection&lt;string&gt;</c> — the node-id sequence the learner had
/// to assemble. Reuses <see cref="FlowChartGrader.Lcs"/> (LCS ratio, the only scoring
/// mode applied to order; the spec §4.4 row does not list <c>exact</c> /
/// <c>adjacent-swap-count</c> for this type).</item>
/// <item><c>GapAnswers: IDictionary&lt;string, Anonymous&gt;</c> where
/// <c>Anonymous.AcceptedTexts: ICollection&lt;string&gt;</c> and optional
/// <c>AcceptedRegexes</c>. Each gap is scored with
/// <see cref="CompletionScoring.Score"/> over the projected
/// <c>AcceptedTexts</c> lists; non-empty <c>AcceptedRegexes</c> are flagged in
/// <c>FailureReason</c> (regex matching is out of scope for auto-grading).</item>
/// </list>
/// The final score is the average of the order score and the gap score.
/// </summary>
public sealed class FlowChartCompletionGrader(ITextNormalizer normalizer) : IGrader
{
    public string Slug => "FLOW_CHART_COMPLETION";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        var correctAns = (FlowChartCompletionAnswer)correct.TypedRecord;

        // ── Order part ───────────────────────────────────────────────────────
        IReadOnlyList<string>? learnerOrder;
        try
        {
            learnerOrder = JsonSerializer.Deserialize<List<string>>(learner.RawJson, Opts);
        }
        catch
        {
            learnerOrder = null;
        }

        var correctOrder = correctAns.Order as IReadOnlyList<string> ?? Array.Empty<string>();
        GradeResult orderResult;
        if (correctOrder.Count == 0)
        {
            // No order component → treat as fully met so it does not penalise the gap score.
            orderResult = new GradeResult(1m, true);
        }
        else
        {
            orderResult = learnerOrder is null
                ? new GradeResult(0m, false, FailureReason: "learner order missing")
                : FlowChartGrader.Lcs(learnerOrder, correctOrder);
        }

        // ── Gap part ─────────────────────────────────────────────────────────
        var hasRegex = correctAns.GapAnswers.Values.Any(v => v.AcceptedRegexes is { Count: > 0 });
        var acceptedTexts = new Dictionary<string, ICollection<string>>(
            correctAns.GapAnswers.Count, StringComparer.Ordinal);
        foreach (var (gapId, accepted) in correctAns.GapAnswers)
            acceptedTexts[gapId] = accepted.AcceptedTexts;

        // Learner gap answers use the same gapId → list-of-strings shape.
        Dictionary<string, ICollection<string>>? learnerGaps = null;
        try
        {
            learnerGaps = JsonSerializer.Deserialize<Dictionary<string, ICollection<string>>>(
                learner.RawJson, Opts);
        }
        catch
        {
            // fall through with null → all gaps score 0
        }

        var gapResult = CompletionScoring.Score(normalizer, learnerGaps, acceptedTexts, norm);

        // ── Combine: average of order and gap scores ────────────────────────
        var combined = (orderResult.AwardedPoints + gapResult.AwardedPoints) / 2m;
        var failure = hasRegex
            ? $"{gapResult.FailureReason}; acceptedRegexes not auto-graded"
            : gapResult.FailureReason;
        return new GradeResult(combined, combined >= 1m, NeedsManualReview: hasRegex, FailureReason: failure);
    }
}
