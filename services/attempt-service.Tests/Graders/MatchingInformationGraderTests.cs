using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="MatchingInformationGrader"/> via
/// <see cref="MatchingScoring"/>. Learner wire: questionId → paragraphId map.
/// Scoring honours <c>scoring</c> enum (same set as MATCHING_HEADING).
/// </summary>
public sealed class MatchingInformationGraderTests
{
    private readonly MatchingInformationGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void AllOrNothing_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"},{"questionId":"q2","paragraphId":"b"}],"scoring":"all-or-nothing"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read(
            """{"q1":"a","q2":"b"}""",
            "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void AllOrNothing_partial_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"},{"questionId":"q2","paragraphId":"b"}],"scoring":"all-or-nothing"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read(
            """{"q1":"a","q2":"WRONG"}""",
            "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Proportional_three_paragraphs_two_correct()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"},{"questionId":"q2","paragraphId":"b"},{"questionId":"q3","paragraphId":"c"}],"scoring":"proportional"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read(
            """{"q1":"a","q2":"b","q3":"WRONG"}""",
            "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(2m / 3m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Afi_full_match_scores_1()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"}],"scoring":"afi"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read("""{"q1":"a"}""", "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Empty_learner_payload_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"}],"scoring":"proportional"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read("""{}""", "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Malformed_learner_json_scores_0()
    {
        var correct = _reader.Read(
            """{"pairs":[{"questionId":"q1","paragraphId":"a"}],"scoring":"proportional"}""",
            "MATCHING_INFORMATION");
        var learner = _reader.Read("""not-json""", "MATCHING_INFORMATION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
    }
}