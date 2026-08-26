using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="SentenceCompletionGrader"/>:
/// single-gap question with <c>acceptedTexts</c> and optional <c>acceptedRegexes</c>.
/// Full credit iff normalised literal match OR regex match (against raw text).
/// </summary>
public sealed class SentenceCompletionGraderTests
{
    private readonly SentenceCompletionGrader _grader = new(new TextNormalizer());
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Exact_text_match_scores_1()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["photosynthesis"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":"photosynthesis"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Different_text_scores_0()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["photosynthesis"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":"respiration"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Normalized_match_with_article_and_punctuation()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["photosynthesis"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read(
            """{"text":"the Photosynthesis!"}""",
            "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Regex_match_scores_1()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":[],"acceptedRegexes":["^pho.*esis$"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":"photosynthesis"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Regex_is_matched_against_raw_text_not_normalized()
    {
        var correct = _reader.Read(
            """{"acceptedRegexes":["^[A-Z]+$"]}""",
            "SENTENCE_COMPLETION");
        // Upper-case required by regex; the normalised value would be lowercase.
        var learner = _reader.Read("""{"text":"HELLO"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }

    [Fact]
    public void Empty_text_scores_0_with_failure_reason()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["anything"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":""}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
        Assert.Equal("no learner text", result.FailureReason);
    }

    [Fact]
    public void Malformed_regex_is_skipped_not_thrown()
    {
        var correct = _reader.Read(
            """{"acceptedRegexes":["[invalid"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":"anything"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        // Should not throw — malformed pattern is silently skipped.
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Accepted_alternative_text_match()
    {
        var correct = _reader.Read(
            """{"acceptedTexts":["photosynthesis","photo-synthesis"]}""",
            "SENTENCE_COMPLETION");
        var learner = _reader.Read("""{"text":"photo-synthesis"}""", "SENTENCE_COMPLETION");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.Equal(1m, result.AwardedPoints);
        Assert.True(result.IsCorrect);
    }
}