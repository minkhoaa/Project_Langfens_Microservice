using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MapLabelGrader"/> via
/// <see cref="CompletionScoring"/>: per-gap normalised exact match.
/// </summary>
public sealed class MapLabelGraderTests
{
    private readonly MapLabelGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void All_gaps_match_scores_1()
    {
        var correct = _reader.Read(
            """{"answers":{"north":["river"],"south":["forest"]}}""",
            "MAP_LABEL");
        var learner = _reader.Read(
            """{"north":["river"],"south":["forest"]}""",
            "MAP_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Partial_match_scores_proportion()
    {
        var correct = _reader.Read(
            """{"answers":{"north":["river"],"south":["forest"],"east":["desert"]}}""",
            "MAP_LABEL");
        var learner = _reader.Read(
            """{"north":["river"],"south":["WRONG"],"east":["desert"]}""",
            "MAP_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void All_wrong_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"north":["river"]}}""",
            "MAP_LABEL");
        var learner = _reader.Read("""{"north":["WRONG"]}""", "MAP_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"north":["river"]}}""",
            "MAP_LABEL");
        var learner = _reader.Read("""{}""", "MAP_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Malformed_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"answers":{"north":["river"]}}""",
            "MAP_LABEL");
        var learner = _reader.Read("""not-json""", "MAP_LABEL");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }
}