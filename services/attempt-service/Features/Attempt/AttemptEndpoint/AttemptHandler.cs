using attempt_service.Contracts.Attempt;

namespace attempt_service.Features.Attempt.AttemptEndpoint;

public static class AttemptHandler
{
    public static Task<IResult> AttemptStartHandler(
        IAttemptService service,
        AttemptStartRequest request,
        CancellationToken token,
        int userId
    ) => service.StartAttempt(request, token, userId);
}