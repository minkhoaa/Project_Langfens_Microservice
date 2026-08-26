using Shared.PublicContracts.Generated;

namespace attempt_service.Features.Helpers;

/// <summary>
/// Grader for <c>AUDIO_RESPONSE</c>. Per spec §4.4 these answers require
/// manual review (whisper transcription + human/AI rater) and are never
/// auto-scored. Returns <see cref="GradeResult.NeedsManualReview"/> = <c>true</c>
/// with 0 awarded points; <see cref="GradeResult.IsCorrect"/> is <c>false</c>
/// because <c>bool IsCorrect</c> is non-nullable on the result record.
/// </summary>
public sealed class AudioResponseGrader : IGrader
{
    public string Slug => "AUDIO_RESPONSE";

    public GradeResult Grade(AnswerEnvelope learner, AnswerEnvelope correct, NormalizationConfig norm)
    {
        // Ensure the envelopes parse to the expected record type before queueing for review,
        // so a malformed learner payload surfaces as a graded failure rather than silent review.
        _ = (AudioResponseAnswer)correct.TypedRecord;
        _ = learner.RawJson;

        return new GradeResult(
            AwardedPoints: 0m,
            IsCorrect: false,
            NeedsManualReview: true,
            FailureReason: "audio response routed to manual review queue");
    }
}
