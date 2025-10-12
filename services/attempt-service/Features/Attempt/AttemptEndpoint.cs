using attempt_service.Features.Attempt.AttemptEndpoint;

namespace attempt_service.Features.Attempt;

public static class AttemptEndpointMapping
{
    public static void MapAttemptEndpoint(this IEndpointRouteBuilder app)
    {
        app.MapGroup("/api/attempt");
        app.MapPost("/attempts:start", AttemptHandler.AttemptStartHandler);
        app.MapGet("/attempts/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptGetByIdHandler);
        app.MapPost("/attempt/autosave/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptAutoSave);
        app.MapPost("/attempt/submit/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptSubmit);
        app.MapGet("/attempt/getresult/{userId:guid}/{attemptId:guid}", AttemptHandler.AttemptGetResult);
        app.MapGet("/attempt/getlistattempt/{userId:guid}", AttemptHandler.GetAttemptList);
        
    }
}
