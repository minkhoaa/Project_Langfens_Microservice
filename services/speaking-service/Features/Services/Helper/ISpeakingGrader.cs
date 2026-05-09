using speaking_service.Contracts;
using speaking_service.Domains.Entities;

namespace speaking_service.Features.Services.Helper;

public interface ISpeakingGrader
{
    Task<SpeakingGradeResult> GradeAsync(ContentSubmission submission, CancellationToken ct);
    SpeakingEvaluation MapToEvaluation(SpeakingGradeResponse response, LlmSpeakingScoreCompact raw);
}
