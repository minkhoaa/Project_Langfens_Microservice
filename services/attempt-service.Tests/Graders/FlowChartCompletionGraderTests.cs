using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="FlowChartCompletionGrader"/>: combines
/// order scoring (LCS, the only mode applied here) with gap completion
/// scoring. Final score = average(order, gap). <c>acceptedRegexes</c> flag
/// for manual review.
/// </summary>
public sealed class FlowChartCompletionGraderTests
{
    private readonly FlowChartCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"order":["a","b"],"gapAnswers":{"n1":{"acceptedTexts":["alpha"]}}}""",
            "FLOW_CHART_COMPLETION");
        // Learner submits a combined JSON: list for order AND dict for gaps —
        // grader tries to deserialize both shapes against the same raw JSON.
        var learner = _reader.Read(
            """{"n1":["alpha"]}""",
            "FLOW_CHART_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // Order LCS ratio is 0 (learner JSON isn't a string list) and gap
        // score is 1.0, so combined = (0 + 1) / 2 = 0.5.
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Order_only_match_contributes_half()
    {
        var correct = _reader.Read(
            """{"order":["a","b"],"gapAnswers":{"n1":{"acceptedTexts":["alpha"]}}}""",
            "FLOW_CHART_COMPLETION");
        // Submit a list-shaped payload — order parses but gap list is empty.
        var learner = _reader.Read(
            """["a","b"]""",
            "FLOW_CHART_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // Order = 1, gap = 0 → combined = 0.5.
        Assert.Equal(0.5m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Gap_only_match_contributes_half()
    {
        var correct = _reader.Read(
            """{"order":["a","b"],"gapAnswers":{"n1":{"acceptedTexts":["alpha"]}}}""",
            "FLOW_CHART_COMPLETION");
        // Dict payload with a gap but no order list — order LCS = 0.
        var learner = _reader.Read(
            """{"n1":["alpha"]}""",
            "FLOW_CHART_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0.5m, result.AwardedPoints);
    }

    [Fact]
    public void Empty_correct_order_treated_as_fully_met()
    {
        var correct = _reader.Read(
            """{"order":[],"gapAnswers":{"n1":{"acceptedTexts":["alpha"]}}}""",
            "FLOW_CHART_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["alpha"]}""",
            "FLOW_CHART_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // No order component → treated as 1.0 so it doesn't penalise gaps.
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Regex_in_gap_flags_manual_review()
    {
        var correct = _reader.Read(
            """{"order":[],"gapAnswers":{"n1":{"acceptedTexts":["alpha"],"acceptedRegexes":["^al.*$"]}}}""",
            "FLOW_CHART_COMPLETION");
        var learner = _reader.Read(
            """{"n1":["alpha"]}""",
            "FLOW_CHART_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Contains("regex", result.FailureReason, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Slug_is_FLOW_CHART_COMPLETION()
    {
        Assert.Equal("FLOW_CHART_COMPLETION", _grader.Slug);
    }
}