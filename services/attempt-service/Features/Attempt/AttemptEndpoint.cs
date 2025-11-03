using attempt_service.Features.Attempt.AttemptEndpoint;
using Shared.Security.Scopes;

namespace attempt_service.Features.Attempt;

public static class AttemptEndpointMapping
{
    public static void MapAttemptEndpoint(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/attempt");
        app.MapPost("/attempts:start", AttemptHandler.AttemptStartHandler)
            .RequireAuthorization(AttemptScope.AttemptStart);
        app.MapGet("/attempts/{attemptId:guid}", AttemptHandler.AttemptGetByIdHandler)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapPost("/attempt/autosave/{attemptId:guid}", AttemptHandler.AttemptAutoSave)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapPost("/attempt/submit/{attemptId:guid}", AttemptHandler.AttemptSubmit)
            .RequireAuthorization(AttemptScope.AttemptSubmit);
        app.MapGet("/attempt/getresult/{attemptId:guid}", AttemptHandler.AttemptGetResult)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapGet("/attempt/getlistattempt", AttemptHandler.GetAttemptList)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        
    }
}
