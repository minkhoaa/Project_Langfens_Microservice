using Microsoft.AspNetCore.Mvc;
using speaking_service.Contracts;
using speaking_service.Features.Services.Admin;
using speaking_service.Features.Services.User;

namespace speaking_service.Features.Handler;

public class SpeakingHandler
{
    public static Task<IResult> SubmitHandler(
        [FromForm] SpeakingSubmitForm submitForm,
        CancellationToken token,
        ISpeakingService service)
        => service.SpeakingSubmit(submitForm, token);
    

    public static Task<IResult> GetExamHandler(Guid examId, CancellationToken token, ISpeakingService service) =>
        service.GetExam(examId, token);

    public static Task<IResult> GetExamListHandler(CancellationToken token, ISpeakingService service) =>
        service.GetExams(token);

    public static Task<IResult> GetHistoryHandler(CancellationToken token, ISpeakingService service) =>
        service.GetHistory(token);

    public static Task<IResult> CreateExamHandler(CreateSpeakingExamRequest request,
        CancellationToken token,
         IAdminService service
    ) => service.CreateExam(request, token);

    public static Task<IResult> UpdateExamHandler(Guid examId, UpdateSpeakingExamRequest request,
        CancellationToken token,
        IAdminService service) => service.UpdateExam(examId, request, token);

    public static Task<IResult> GetAdminExamsHandler(CancellationToken token, IAdminService service) =>
        service.GetAllExams(token);

    public static Task<IResult> DeleteExamHandler(Guid examId, CancellationToken token, IAdminService service) =>
        service.DeleteExam(examId, token);
}
