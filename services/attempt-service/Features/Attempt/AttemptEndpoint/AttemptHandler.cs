using System.Security.Claims;
using attempt_service.Contracts.Attempt;
using Microsoft.AspNetCore.Mvc;
using Shared.Security.Claims;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public static class AttemptHandler
{
    public static Task<IResult> AttemptStartHandler(
        IAttemptService service, 
        AttemptStartRequest request,
        CancellationToken token,
        ClaimsPrincipal user
    ) => service.StartAttempt(request, token, user);

    public static Task<IResult> AttemptGetByIdHandler(
        ClaimsPrincipal user, 
        [FromRoute] Guid attemptId,
        CancellationToken token,
        [FromServices] IAttemptService service
    ) => service.GetAttemptById(new AttemptGetRequest(attemptId, user), token);
    

    public static Task<IResult> AttemptAutoSave(
        [FromRoute] Guid attemptId,
        ClaimsPrincipal user,
        AutosaveRequest req,
        CancellationToken token,
        IAttemptService service
    ) => service.Autosave(attemptId, user, req, token);

    public static Task<IResult> AttemptSubmit(
        ClaimsPrincipal user,
        [FromRoute] Guid attemptId,
        CancellationToken token,
        IAttemptService service)
        => service.Submit(attemptId, user, token);

    public static Task<IResult> AttemptGetResult(
        [FromRoute] Guid attemptId,
        ClaimsPrincipal user,
        CancellationToken token,
        IAttemptService service
    ) => service.GetResult(attemptId, user, token);

    public static Task<IResult> GetAttemptList(
        ClaimsPrincipal user,
        int page,
        int pageSize,
        string? status,
        Guid? examId,
        CancellationToken token,
        IAttemptService service
    ) => service.GetAttemptList(user, page, pageSize, status, examId, token);
}
