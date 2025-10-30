using attempt_service.Contracts.Attempt;
using Microsoft.AspNetCore.Mvc;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public static class AttemptHandler
{
    public static Task<IResult> AttemptStartHandler(
        IAttemptService service, 
        AttemptStartRequest request,
        CancellationToken token,
        Guid userId
    ) => service.StartAttempt(request, token, userId);

    public static Task<IResult> AttemptGetByIdHandler(
        [FromRoute] Guid userId,
        [FromRoute] Guid attemptId,
        CancellationToken token,
        [FromServices] IAttemptService service
    ) => service.GetAttemptById(new AttemptGetRequest(attemptId, userId), token);

    public static Task<IResult> AttemptAutoSave(
        [FromRoute] Guid attemptId,
        [FromRoute] Guid userId,
        AutosaveRequest req,
        CancellationToken token,
        IAttemptService service
    ) => service.Autosave(attemptId, userId, req, token);

    public static Task<IResult> AttemptSubmit(
        [FromRoute] Guid userId,
        [FromRoute] Guid attemptId,
        CancellationToken token,
        IAttemptService service)
        => service.Submit(attemptId, userId, token);

    public static Task<IResult> AttemptGetResult(
        [FromRoute] Guid attemptId,
        [FromRoute] Guid userId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetResult(attemptId, userId, token);

    public static Task<IResult> GetAttemptList(
        Guid userId,
        int page,
        int pageSize,
        string? status,
        Guid? examId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetAttemptList(userId, page, pageSize, status, examId, token);
}
