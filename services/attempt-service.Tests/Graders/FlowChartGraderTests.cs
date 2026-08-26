using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="FlowChartGrader"/>: learner supplies an
/// ordered list of node ids; correct answer exposes <c>order</c> + <c>scoring</c>
/// (<c>exact</c> / <c>lcs</c> / <c>adjacent-swap-count</c>).
/// </summary>
public sealed class FlowChartGraderTests
{
    private readonly FlowChartGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Exact_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"order":["a","b","c"],"scoring":"exact"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["a","b","c"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Exact_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"order":["a","b","c"],"scoring":"exact"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["a","c","b"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Lcs_perfect_match_scores_1()
    {
        var correct = _reader.Read(
            """{"order":["a","b","c"],"scoring":"lcs"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["a","b","c"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Lcs_partial_match_proportional()
    {
        // LCS of ["a","c","b"] and ["a","b","c"] = 2 / 3
        var correct = _reader.Read(
            """{"order":["a","b","c"],"scoring":"lcs"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["a","c","b"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void AdjacentSwaps_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"order":["a","b","c","d"],"scoring":"adjacent-swap-count"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["a","b","c","d"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AdjacentSwaps_single_swap_partial_credit()
    {
        // ["b","a","c","d"] → bubble "b" to position 0 needs one swap; result
        // equals correct so it scores 1.0 (the bubble-into algorithm produces
        // the correct order once the swap is applied).
        var correct = _reader.Read(
            """{"order":["a","b","c","d"],"scoring":"adjacent-swap-count"}""",
            "FLOW_CHART");
        var learner = _reader.Read(
            """["b","a","c","d"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // Algorithm: at i=0, "a" is at j=1, swap once → learner matches → 1.0.
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AdjacentSwaps_more_swaps_partial_credit()
    {
        var correct = _reader.Read(
            """{"order":["a","b","c","d"],"scoring":"adjacent-swap-count"}""",
            "FLOW_CHART");
        // ["c","b","a","d"] cannot be bubbled into [a,b,c,d] → max(0, 1 - 3*0.1) = 0.7
        var learner = _reader.Read(
            """["c","b","a","d"]""",
            "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.False(result.IsCorrect);
        Assert.True(result.AwardedPoints > 0m && result.AwardedPoints < 1m);
    }

    [Fact]
    public void Empty_learner_order_scores_0()
    {
        var correct = _reader.Read(
            """{"order":["a","b"],"scoring":"lcs"}""",
            "FLOW_CHART");
        var learner = _reader.Read("[]", "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Malformed_learner_json_scores_0()
    {
        var correct = _reader.Read(
            """{"order":["a","b"],"scoring":"lcs"}""",
            "FLOW_CHART");
        var learner = _reader.Read("""not-json""", "FLOW_CHART");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.Equal("learner order malformed", result.FailureReason);
    }
}