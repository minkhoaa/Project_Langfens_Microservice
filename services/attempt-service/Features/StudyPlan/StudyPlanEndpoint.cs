using attempt_service.Features.Helpers;

namespace attempt_service.Features.StudyPlan;

public static class StudyPlanEndpoint
{
    public static void MapStudyPlanEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/study-plan")
            .WithTags("Study Plan")
            .RequireAuthorization();

        group.MapPost("/goals", Handler.CreateGoal)
            .WithName("CreateStudyGoal")
            .WithDescription("Create or update a study goal");

        group.MapGet("/goals/active", Handler.GetActiveGoal)
            .WithName("GetActiveStudyGoal")
            .WithDescription("Get the active study goal");

        group.MapGet("/progress", Handler.GetProgress)
            .WithName("GetStudyProgress")
            .WithDescription("Get progress towards the active goal");

        group.MapDelete("/goals/{goalId:guid}", Handler.DeleteGoal)
            .WithName("DeleteStudyGoal")
            .WithDescription("Delete a study goal");
    }

    private static class Handler
    {
        public static Task<IResult> CreateGoal(
            CreateGoalRequest request,
            CancellationToken token,
            IStudyPlanService service,
            IUserContext userContext
        ) => service.CreateOrUpdateGoal(userContext.UserId, request, token);

        public static Task<IResult> GetActiveGoal(
            CancellationToken token,
            IStudyPlanService service,
            IUserContext userContext
        ) => service.GetActiveGoal(userContext.UserId, token);

        public static Task<IResult> GetProgress(
            CancellationToken token,
            IStudyPlanService service,
            IUserContext userContext
        ) => service.GetProgress(userContext.UserId, token);

        public static Task<IResult> DeleteGoal(
            Guid goalId,
            CancellationToken token,
            IStudyPlanService service,
            IUserContext userContext
        ) => service.DeleteGoal(userContext.UserId, goalId, token);
    }
}
