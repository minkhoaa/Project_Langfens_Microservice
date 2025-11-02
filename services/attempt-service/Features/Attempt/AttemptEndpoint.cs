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
        app.MapGet("/attempts/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptGetByIdHandler)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapPost("/attempt/autosave/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptAutoSave)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapPost("/attempt/submit/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptSubmit)
            .RequireAuthorization(AttemptScope.AttemptSubmit);
        app.MapGet("/attempt/getresult/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptGetResult)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        app.MapGet("/attempt/getlistattempt/{userId:guid}", AttemptHandler.GetAttemptList)
            .RequireAuthorization(AttemptScope.AttemptReadAny);
        
    }
}
