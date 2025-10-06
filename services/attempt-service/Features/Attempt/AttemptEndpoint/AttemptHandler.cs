using attempt_service.Contracts.Attempt;
using Microsoft.AspNetCore.Mvc;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public static class AttemptHandler
{
    public static Task<IResult> AttemptStartHandler(
        IAttemptService service,
        AttemptStartRequest request,
        CancellationToken token,
        int userId
    ) => service.StartAttempt(request, token, userId);

    public static Task<IResult> AttemptGetByIdHandler(
        [FromRoute] int userId,
        [FromRoute] int attemptId,
        CancellationToken token,
        [FromServices] IAttemptService service
    ) => service.GetAttemptById(new AttemptGetRequest(attemptId, userId), token);

    public static Task<IResult> AttemptAutoSave(
        [FromRoute] int attemptId,
        [FromRoute] int userId,
        AutosaveRequest req,
        CancellationToken token,
        IAttemptService service
    ) => service.Autosave(attemptId, userId, req, token);

    public static Task<IResult> AttemptSubmit(
        [FromRoute] int userId,
        [FromRoute] int attemptId,
        CancellationToken token,
        IAttemptService service)
        => service.Submit(attemptId, userId, token);
}