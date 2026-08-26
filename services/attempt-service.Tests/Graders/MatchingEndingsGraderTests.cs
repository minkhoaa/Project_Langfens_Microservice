using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MatchingEndingsGrader"/> via
/// <see cref="MatchingScoring"/>. Learner wire: beginId → endId map.
/// </summary>
public sealed class MatchingEndingsGraderTests
{
    private readonly MatchingEndingsGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"beginId":"b1","endId":"e1"},{"beginId":"b2","endId":"e2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_ENDINGS");
        var learner = _reader.Read(
            """{"b1":"e1","b2":"e2"}""",
            "MATCHING_ENDINGS");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"beginId":"b1","endId":"e1"},{"beginId":"b2","endId":"e2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_ENDINGS");
        var learner = _reader.Read(
            """{"b1":"e1","b2":"WRONG"}""",
            "MATCHING_ENDINGS");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_partial_match()
    {
        var correct = _reader.Read(
            """{"pairs":[{"beginId":"b1","endId":"e1"},{"beginId":"b2","endId":"e2"},{"beginId":"b3","endId":"e3"}],"scoring":"proportional"}""",
            "MATCHING_ENDINGS");
        var learner = _reader.Read(
            """{"b1":"e1","b2":"WRONG","b3":"e3"}""",
            "MATCHING_ENDINGS");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"beginId":"b1","endId":"e1"}],"scoring":"afi"}""",
            "MATCHING_ENDINGS");
        var learner = _reader.Read("""{"b1":"e1"}""", "MATCHING_ENDINGS");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Rubric_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"pairs":[{"beginId":"b1","endId":"e1"}],"scoring":"rubric"}""",
            "MATCHING_ENDINGS");
        var learner = _reader.Read("""{"b1":"e1"}""", "MATCHING_ENDINGS");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
    }
}