using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="TableCompletionGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class TableCompletionGraderTests
{
    private readonly TableCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"row1":["1975"],"row2":["London"]}}""",
            "TABLE_COMPLETION");
        var learner = _reader.Read(
            """{"row1":["1975"],"row2":["London"]}""",
            "TABLE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"r1":["1975"],"r2":["London"],"r3":["Paris"]}}""",
            "TABLE_COMPLETION");
        var learner = _reader.Read(
            """{"r1":["1975"],"r2":["Lyon"],"r3":["Paris"]}""",
            "TABLE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"r1":["1975"],"r2":["London"]}}""",
            "TABLE_COMPLETION");
        var learner = _reader.Read(
            """{"r1":["2000"],"r2":["Tokyo"]}""",
            "TABLE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Trailing_punctuation_does_not_block_match()
    {
        var correct = _reader.Read(
            """{"answers":{"r1":["1975."]}}""",
            "TABLE_COMPLETION");
        var learner = _reader.Read(
            """{"r1":["1975"]}""",
            "TABLE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Malformed_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"r1":["1975"]}}""",
            "TABLE_COMPLETION");
        var learner = _reader.Read("""{"r1":[12345]}""", "TABLE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }
}