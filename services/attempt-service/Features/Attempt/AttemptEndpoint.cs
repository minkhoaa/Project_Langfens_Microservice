using attempt_service.Features.Attempt.AttemptEndpoint;
using Shared.Security.Scopes;

namespace attempt_service.Features.Attempt;

public static class AttemptEndpointMapping
{
    public static void MapAttemptEndpoint(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/attempt");
        group.MapPost("/attempts:start", AttemptHandler.AttemptStartHandler)
            .RequireAuthorization(AttemptScope.AttemptStart);
        group.MapGet("/attempts/{attemptId:guid}", AttemptHandler.AttemptGetByIdHandler)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapPost("/attempt/autosave/{attemptId:guid}", AttemptHandler.AttemptAutoSave)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapPost("/attempt/submit/{attemptId:guid}", AttemptHandler.AttemptSubmit)
            .RequireAuthorization(AttemptScope.AttemptSubmit);
        group.MapGet("/attempt/getresult/{attemptId:guid}", AttemptHandler.AttemptGetResult)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapGet("/attempt/getlistattempt", AttemptHandler.GetAttemptList)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
    }
}
