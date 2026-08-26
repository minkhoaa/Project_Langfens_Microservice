using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="SummaryCompletionGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class SummaryCompletionGraderTests
{
    private readonly SummaryCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"1":["alpha"],"2":["beta"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read(
            """{"1":["alpha"],"2":["beta"]}""",
            "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"1":["alpha"],"2":["beta"],"3":["gamma"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read(
            """{"1":["alpha"],"2":["WRONG"],"3":["gamma"]}""",
            "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"1":["alpha"],"2":["beta"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read(
            """{"1":["WRONG"],"2":["WRONG"]}""",
            "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"1":["alpha"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read("""{}""", "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Normalization_lets_article_drop_match()
    {
        // "the alpha" should still match "alpha" after article-drop normalisation.
        var correct = _reader.Read(
            """{"answers":{"1":["alpha"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read(
            """{"1":["The Alpha"]}""",
            "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Accepted_alternatives_match()
    {
        var correct = _reader.Read(
            """{"answers":{"1":["alpha","first"]}}""",
            "SUMMARY_COMPLETION");
        var learner = _reader.Read(
            """{"1":["first"]}""",
            "SUMMARY_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Slug_is_SUMMARY_COMPLETION()
    {
        Assert.Equal("SUMMARY_COMPLETION", _grader.Slug);
    }
}