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
        group.MapGet("/{attemptId:guid}", AttemptHandler.AttemptGetByIdHandler)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapPost("/autosave/{attemptId:guid}", AttemptHandler.AttemptAutoSave)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapPost("/submit/{attemptId:guid}", AttemptHandler.AttemptSubmit)
            .RequireAuthorization(AttemptScope.AttemptSubmit);
        group.MapGet("/getresult/{attemptId:guid}", AttemptHandler.AttemptGetResult)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapGet("/getlistattempt", AttemptHandler.GetAttemptList)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
        group.MapGet("/placement", AttemptHandler.GetUserLatestPlacement)
            .RequireAuthorization(AttemptScope.AttemptReadOwn);
    }
    public static void MapAdminEndpoint(this IEndpointRouteBuilder router)
    {
        var admin = router.MapGroup("/api/admin/attempt")
          .RequireAuthorization(AttemptScope.AttemptReadAny);
        admin.MapGet("/", AttemptHandler.GetAttemptListAdmin);

    }
}
