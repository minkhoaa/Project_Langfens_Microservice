using attempt_service.Features.Helpers;


namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="ShortAnswerGrader"/>: learner wire is the
/// same <c>ShortAnswerAnswer</c> record (single acceptedTexts entry). Grading
/// uses normalised literal match then anchored regex (case-insensitive,
/// culture-invariant) against the raw learner text.
/// </summary>
public sealed class ShortAnswerGraderTests
{
    private readonly ShortAnswerGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Exact_normalized_match_scores_1()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["Paris"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void No_match_scores_0_with_failure_reason()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["london"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no accepted match", result.FailureReason);
    }

    [Fact]
    public void Empty_learner_text_scores_0()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["   "]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("empty answer", result.FailureReason);
    }

    [Fact]
    public void Regex_match_scores_1()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":[],"acceptedRegexes":["par[ie]s"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Regex_is_anchored_when_user_did_not_anchor()
    {
        // "paris" pattern unanchored → grader should anchor to ^paris$ so it
        // does not match "paris, texas".
        var correct = _reader.Read(
            """{"acceptedRegexes":["paris"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["paris, texas"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Regex_is_case_insensitive()
    {
        var correct = _reader.Read(
            """{"acceptedRegexes":["PARIS"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void User_supplied_anchors_are_preserved()
    {
        // User-supplied ^pattern$ → grader should NOT double-anchor.
        var correct = _reader.Read(
            """{"acceptedRegexes":["^paris$"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Malformed_regex_is_silently_skipped()
    {
        var correct = _reader.Read(
            """{"acceptedRegexes":["[invalid"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["paris"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // Should not throw — malformed pattern is silently skipped.
        Assert.False(result.IsCorrect);
        Assert.Equal(0m, result.AwardedPoints);
    }

    [Fact]
    public void Accepted_alternative_match()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["paris","city of light"]}""",
            "SHORT_ANSWER");
        var learner = _reader.Read(
            """{"acceptedTexts":["City of Light"]}""",
            "SHORT_ANSWER");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }
}