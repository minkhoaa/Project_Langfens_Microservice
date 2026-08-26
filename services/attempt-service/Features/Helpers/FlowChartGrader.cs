using System.Text.Json;
using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>FLOW_CHART</c>. Learner supplies an <c>ICollection&lt;string&gt;</c>
/// node-id order; correct answer exposes <c>Order</c> + <c>Scoring</c>
/// (<c>exact</c> / <c>lcs</c> / <c>adjacent-swap-count</c>). All scoring is exposed as
/// <see cref="public static"/> helpers so <c>FlowChartCompletionGrader</c> can reuse
/// <see cref="Lcs"/>.
/// </summary>
public sealed class FlowChartGrader : IGrader
{
    public string Slug => "FLOW_CHART";

    private static readonly JsonSerializerOptions Opts = new(JsonSerializerDefaults.Web);

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig _)
    {
        var correctAns = (FlowChartAnswer)correct.TypedRecord;

        IReadOnlyList<string>? learnerOrder;
        try
        {
            var arr = JsonSerializer.Deserialize<List<string>>(learner.RawJson, Opts);
            learnerOrder = arr;
        }
        catch
        {
            return new GradeResult(0m, false, FailureReason: "learner order malformed");
        }
        if (learnerOrder is null)
            return new GradeResult(0m, false, FailureReason: "learner order empty");

        var correctOrder = correctAns.Order as IReadOnlyList<string> ?? Array.Empty<string>();
        var mode = correctAns.Scoring ?? FlowChartAnswerScoring.Lcs;

        return mode switch
        {
            FlowChartAnswerScoring.Exact => Exact(learnerOrder, correctOrder),
            FlowChartAnswerScoring.AdjacentSwapCount => AdjacentSwaps(learnerOrder, correctOrder),
            _ => Lcs(learnerOrder, correctOrder),
        };
    }

    /// <summary>
    /// <c>exact</c>: full credit iff both sequences are equal as sets-with-order.
    /// </summary>
    public static GradeResult Exact(IReadOnlyList<string> a, IReadOnlyList<string> b)
    {
        var ok = a.SequenceEqual(b);
        return new GradeResult(ok ? 1m : 0m, ok);
    }

    /// <summary>
    /// <c>lcs</c>: credit = longest-common-subsequence length / correct length.
    /// </summary>
    public static GradeResult Lcs(IReadOnlyList<string> a, IReadOnlyList<string> b)
    {
        var len = LongestCommonSubsequence(a, b);
        var ratio = b.Count == 0 ? 0m : (decimal)len / b.Count;
        return new GradeResult(ratio, ratio >= 1m);
    }

    /// <summary>
    /// <c>adjacent-swap-count</c>: bubble <c>a</c> into <c>b</c> position-by-position;
    /// credit = max(0, 1 − swaps * 0.1); full credit iff the result equals <c>b</c>.
    /// </summary>
    public static GradeResult AdjacentSwaps(IReadOnlyList<string> a, IReadOnlyList<string> b)
    {
        var arr = a.ToList();
        int swaps = 0;
        for (var i = 0; i < arr.Count; i++)
        {
            var j = i;
            while (j < arr.Count && arr[j] != b[i]) j++;
            while (j > i)
            {
                (arr[j], arr[j - 1]) = (arr[j - 1], arr[j]);
                j--;
                swaps++;
            }
        }
        var ok = arr.SequenceEqual(b);
        var score = ok ? 1m : Math.Max(0m, 1m - swaps * 0.1m);
        return new GradeResult(score, ok);
    }

    /// <summary>
    /// Standard O(n·m) dynamic-programming LCS. Bounded by the per-question
    /// <c>MinLength(2) / MaxLength(12)</c> cap on <c>FlowChartAnswer.Order</c>, so the
    /// worst case is ~144 cells — negligible.
    /// </summary>
    public static int LongestCommonSubsequence(IReadOnlyList<string> a, IReadOnlyList<string> b)
    {
        var n = a.Count;
        var m = b.Count;
        var dp = new int[n + 1, m + 1];
        for (var i = 1; i <= n; i++)
            for (var j = 1; j <= m; j++)
                dp[i, j] = a[i - 1] == b[j - 1]
                    ? dp[i - 1, j - 1] + 1
                    : Math.Max(dp[i - 1, j], dp[i, j - 1]);
        return dp[n, m];
    }
}
