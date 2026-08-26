using attempt_service.Features.Helpers;
using Xunit;

namespace attempt_service.Tests.Graders;

/// <summary>
/// Locks the contract of <see cref="AudioResponseGrader"/>: always
/// <see cref="GradeResult.NeedsManualReview"/> = true, 0 awarded points,
/// <see cref="GradeResult.IsCorrect"/> = false. The grader does NOT consume
/// the learner text — whisper + human/AI rater handles the response.
/// </summary>
public sealed class AudioResponseGraderTests
{
    private readonly AudioResponseGrader _grader = new();
    private readonly AnswerEnvelopeReader _reader = new();

    [Fact]
    public void Always_flags_for_manual_review()
    {
        var correct = _reader.Read(
            """{"acceptedTranscriptions":["hello world"]}""",
            "AUDIO_RESPONSE");
        var learner = _reader.Read(
            """{"audioBlobUrl":"https://example.com/audio.wav"}""",
            "AUDIO_RESPONSE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }

    [Fact]
    public void Failure_reason_explains_routing()
    {
        var correct = _reader.Read(
            """{"acceptedTranscriptions":["hello world"]}""",
            "AUDIO_RESPONSE");
        var learner = _reader.Read(
            """{"audioBlobUrl":"https://example.com/audio.wav"}""",
            "AUDIO_RESPONSE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.NotNull(result.FailureReason);
        Assert.Contains("manual review", result.FailureReason);
    }

    [Fact]
    public void Slug_is_AUDIO_RESPONSE()
    {
        Assert.Equal("AUDIO_RESPONSE", _grader.Slug);
    }

    [Fact]
    public void Manual_review_is_independent_of_learner_payload()
    {
        // Empty learner JSON should still flag for manual review (not throw).
        var correct = _reader.Read(
            """{"acceptedTranscriptions":["hello"]}""",
            "AUDIO_RESPONSE");
        var learner = _reader.Read("""{}""", "AUDIO_RESPONSE");
        var result = _grader.Grade(learner, correct, NormalizationConfig.Default);
        Assert.True(result.NeedsManualReview);
        Assert.Equal(0m, result.AwardedPoints);
        Assert.False(result.IsCorrect);
    }
}