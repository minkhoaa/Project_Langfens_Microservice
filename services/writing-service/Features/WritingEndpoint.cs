using Shared.Security.Roles;
using writing_service.Features.Handler;

namespace writing_service.Features;

public static class WritingEndpoint
{
    public static void MapWritingEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/writing");
        app.MapPost("/grade", WritingHandler.SubmitHandler).RequireAuthorization(Roles.User);
        app.MapGet("/exams", WritingHandler.GetExamListHandler);
        app.MapPost("/start/{examId}", WritingHandler.StartWritingExamHandler);
        app.MapGet("/exams/{examId:guid}", WritingHandler.GetExamHandler);
        app.MapGet("/history", WritingHandler.GetHistoryHandler).RequireAuthorization(Roles.User);
        app.MapGet("/history/{submissionId:guid}", WritingHandler.GetHistoryDetailHandler)
            .RequireAuthorization(Roles.User);
        
    }
    public static void MapWritingAdminEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/admin/writing");
        app.MapGet("/exams", WritingHandler.GetAdminExamsHandler).RequireAuthorization(Roles.Admin);
        app.MapPost("/create", WritingHandler.CreateExamHandler).RequireAuthorization(Roles.Admin);
        app.MapPost("/exams", WritingHandler.CreateExamHandler).RequireAuthorization(Roles.Admin);
        app.MapPut("/exams/{examId:guid}", WritingHandler.UpdateExamHandler).RequireAuthorization(Roles.Admin);
        app.MapDelete("/exams/{examId:guid}", WritingHandler.DeleteExamHandler).RequireAuthorization(Roles.Admin);

    }
}
