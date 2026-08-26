using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MatchingFeaturesGrader"/> via
/// <see cref="MatchingScoring"/>. Learner wire: itemId → featureId map.
/// </summary>
public sealed class MatchingFeaturesGraderTests
{
    private readonly MatchingFeaturesGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","featureId":"f1"},{"itemId":"i2","featureId":"f2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_FEATURES");
        var learner = _reader.Read(
            """{"i1":"f1","i2":"f2"}""",
            "MATCHING_FEATURES");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","featureId":"f1"},{"itemId":"i2","featureId":"f2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_FEATURES");
        var learner = _reader.Read(
            """{"i1":"f1","i2":"WRONG"}""",
            "MATCHING_FEATURES");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_partial_match()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","featureId":"f1"},{"itemId":"i2","featureId":"f2"}],"scoring":"proportional"}""",
            "MATCHING_FEATURES");
        var learner = _reader.Read(
            """{"i1":"f1","i2":"WRONG"}""",
            "MATCHING_FEATURES");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0.5m, result.AwardedPoints);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","featureId":"f1"}],"scoring":"afi"}""",
            "MATCHING_FEATURES");
        var learner = _reader.Read("""{"i1":"f1"}""", "MATCHING_FEATURES");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Rubric_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","featureId":"f1"}],"scoring":"rubric"}""",
            "MATCHING_FEATURES");
        var learner = _reader.Read("""{"i1":"f1"}""", "MATCHING_FEATURES");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
    }
}