using writing_service.Contracts;
using writing_service.Features.Service.Admin;
using writing_service.Features.Service.User;

namespace writing_service.Features.Handler;

public static class WritingHandler
{
    public static Task<IResult> SubmitHandler(WritingSubmissionRequest request,
        CancellationToken token, IWritingService service)
    {
        return service.WritingSubmit(request, token);
    }

    public static Task<IResult> StartWritingExamHandler(Guid examId, CancellationToken token,
        IWritingService service
    ) => service.StartWritingExam(examId, token);


    public static Task<IResult> GetExamHandler(Guid examId, CancellationToken token, IWritingService service) =>
        service.GetExam(examId, token);

    public static Task<IResult> GetExamListHandler(CancellationToken token, IWritingService service) =>
        service.GetExams(token);

    public static Task<IResult> GetHistoryHandler(CancellationToken token, IWritingService service) =>
        service.GetHistory(token);

    public static Task<IResult> GetHistoryDetailHandler(Guid submissionId, Guid? evaluationId, CancellationToken token,
        IWritingService service) =>
        service.GetHistoryInDetail(submissionId, evaluationId, token);

    public static Task<IResult> CreateExamHandler(CreateExamRequest request,
        CancellationToken token,
        IAdminService service
    ) => service.CreateExam(request, token);

    public static Task<IResult> UpdateExamHandler(Guid examId, UpdateExamRequest request,
        CancellationToken token,
        IAdminService service
    ) => service.UpdateExam(examId, request, token);

    public static Task<IResult> GetAdminExamsHandler(CancellationToken token, IAdminService service) =>
        service.GetAllExams(token);

    public static Task<IResult> DeleteExamHandler(Guid examId, CancellationToken token, IAdminService service) =>
        service.DeleteExam(examId, token);
}
