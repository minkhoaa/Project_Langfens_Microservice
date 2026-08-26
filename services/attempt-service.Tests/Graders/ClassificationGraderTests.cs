using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="ClassificationGrader"/> via
/// <see cref="MatchingScoring"/>. Learner wire: itemId → categoryId map.
/// </summary>
public sealed class ClassificationGraderTests
{
    private readonly ClassificationGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","categoryId":"c1"},{"itemId":"i2","categoryId":"c2"}],"scoring":"all-or-nothing"}""",
            "CLASSIFICATION");
        var learner = _reader.Read(
            """{"i1":"c1","i2":"c2"}""",
            "CLASSIFICATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","categoryId":"c1"},{"itemId":"i2","categoryId":"c2"}],"scoring":"all-or-nothing"}""",
            "CLASSIFICATION");
        var learner = _reader.Read(
            """{"i1":"c1","i2":"WRONG"}""",
            "CLASSIFICATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_partial_match()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","categoryId":"c1"},{"itemId":"i2","categoryId":"c2"}],"scoring":"proportional"}""",
            "CLASSIFICATION");
        var learner = _reader.Read(
            """{"i1":"c1","i2":"WRONG"}""",
            "CLASSIFICATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0.5m, result.AwardedPoints);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","categoryId":"c1"}],"scoring":"afi"}""",
            "CLASSIFICATION");
        var learner = _reader.Read("""{"i1":"c1"}""", "CLASSIFICATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Rubric_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"pairs":[{"itemId":"i1","categoryId":"c1"}],"scoring":"rubric"}""",
            "CLASSIFICATION");
        var learner = _reader.Read("""{"i1":"c1"}""", "CLASSIFICATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Slug_is_CLASSIFICATION()
    {
        Assert.Equal("CLASSIFICATION", _grader.Slug);
    }
}