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

    public static Task<IResult> CreateExamHandler(CreateExamRequest request,
        CancellationToken token,
        IAdminService service
    ) => service.CreateExam(request, token);
}