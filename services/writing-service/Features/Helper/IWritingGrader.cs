using writing_service.Contracts;

namespace writing_service.Features.Helper;

public interface IWritingGrader
{
    Task<WritingGradeResult> GradeAsync(ContentSubmission submission, CancellationToken ct);
}