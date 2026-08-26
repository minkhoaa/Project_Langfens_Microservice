using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MatchingHeadingGrader"/> via
/// <see cref="MatchingScoring"/>. Learner wire: paragraphId → headingId map.
/// Scoring honours <c>scoring</c> enum (<c>all-or-nothing</c> /
/// <c>proportional</c> / <c>afi</c> / <c>rubric</c>).
/// </summary>
public sealed class MatchingHeadingGraderTests
{
    private readonly MatchingHeadingGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"},{"paragraphId":"p2","headingId":"h2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read(
            """{"p1":"h1","p2":"h2"}""",
            "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"},{"paragraphId":"p2","headingId":"h2"}],"scoring":"all-or-nothing"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read(
            """{"p1":"h1","p2":"WRONG"}""",
            "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_partial_match()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"},{"paragraphId":"p2","headingId":"h2"}],"scoring":"proportional"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read(
            """{"p1":"h1","p2":"WRONG"}""",
            "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0.5m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"}],"scoring":"afi"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read(
            """{"p1":"h1"}""",
            "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Rubric_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"}],"scoring":"rubric"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read(
            """{"p1":"h1"}""",
            "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.Contains("rubric", result.FailureReason);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"paragraphId":"p1","headingId":"h1"}],"scoring":"proportional"}""",
            "MATCHING_HEADING");
        var learner = _reader.Read("""{}""", "MATCHING_HEADING");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Slug_is_MATCHING_HEADING()
    {
        Assert.Equal("MATCHING_HEADING", _grader.Slug);
    }
}