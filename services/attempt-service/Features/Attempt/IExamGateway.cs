namespace attempt_service.Features.Attempt;

/// <summary>
/// Reads exam definitions + correct answers from exam-service over gRPC.
/// Task 20 replaces the temporary stub with the real
/// <see cref="ExamGateway"/> using the <c>ExamInternal</c> client.
/// </summary>
public interface IExamGateway
{
    /// <summary>
    /// Returns per-question correct-answer JSON envelopes keyed by question id.
    /// Used by <c>AttemptFlow.SubmitAsync</c> to feed graders.
    /// <paramref name="showAnswers"/> propagates to the gRPC <c>show_answers</c> flag;
    /// when false, exam-service returns an empty <c>Struct</c> for each
    /// <c>correct_answer</c> and this gateway skips those questions.
    /// </summary>
    Task<IReadOnlyDictionary<Guid, string>> GetCorrectAnswersAsync(
        Guid examId, bool showAnswers, CancellationToken ct);

    /// <summary>
    /// Loads the learner-facing <see cref="PaperJson"/> envelope for the given
    /// exam. Used by <c>StartAttemptEndpoint</c> to persist the snapshot the
    /// learner will grade against. <c>correctAnswer</c> is omitted
    /// (showAnswers=false on the wire) since it's stripped at the source.
    /// </summary>
    Task<PaperJson> GetPaperJsonAsync(Guid examId, CancellationToken ct);
}