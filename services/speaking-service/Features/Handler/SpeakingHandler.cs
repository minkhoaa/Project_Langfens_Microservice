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
    {
        return service.SpeakingSubmit(submitForm, token);
    }

    public static Task<IResult> CreateExamHandler(CreateSpeakingExamRequest request,
        CancellationToken token,
         IAdminService service
    ) => service.CreateExam(request, token);
}