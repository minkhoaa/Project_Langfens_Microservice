using System.Security.Claims;
using attempt_service.Contracts.Attempt;
using Microsoft.AspNetCore.Mvc;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public static class AttemptHandler
{
    public static Task<IResult> AttemptStartHandler(
        IAttemptService service,
        AttemptStartRequest request,
        CancellationToken token
    ) => service.StartAttempt(request, token);

    public static Task<IResult> AttemptGetByIdHandler(
        [FromRoute] Guid attemptId,
        CancellationToken token,
        [FromServices] IAttemptService service
    ) => service.GetAttemptById(attemptId, token);

    public static Task<IResult> GetPreviousAttempt(
            Guid examId,
           CancellationToken token,
           [FromServices] IAttemptService service
       ) => service.GetPreviousTurn(examId, token);

    public static Task<IResult> AttemptAutoSave(
        [FromRoute] Guid attemptId,
        ClaimsPrincipal user,
        AutosaveRequest req,
        CancellationToken token,
        IAttemptService service
    ) => service.Autosave(attemptId, req, token);

    public static Task<IResult> AttemptSubmit(
        [FromRoute] Guid attemptId,
        CancellationToken token,
        IAttemptService service)
        => service.Submit(attemptId, token);

    public static Task<IResult> AttemptGetResult(
        [FromRoute] Guid attemptId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetResult(attemptId, token);

    public static Task<IResult> GetAttemptList(
        ClaimsPrincipal user,
        int page,
        int pageSize,
        string? status,
        Guid? examId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetAttemptList(page, pageSize, status, examId, token);

    public static Task<IResult> GetAttemptListAdmin(
        int page,
        int pageSize,
        string? status,
        Guid? examId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetAllAttempts(page, pageSize, status, examId, token);

    public static Task<IResult> GetUserLatestPlacement(CancellationToken token, IAttemptService service)
        => service.GetLatestPlacement(token);

    public static Task<IResult> GetPlacementCompletionStatus(CancellationToken token, IAttemptService service)
        => service.GetPlacementCompletionStatus(token);
}
