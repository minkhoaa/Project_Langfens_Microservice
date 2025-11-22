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
        app.MapGet("/exams/{examId:guid}", WritingHandler.GetExamHandler);
        app.MapGet("/history", WritingHandler.GetHistoryHandler).RequireAuthorization(Roles.User);
        
    }
    public static void MapWritingAdminEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/admin/writing");
        app.MapPost("/create", WritingHandler.CreateExamHandler);
        app.MapPost("/exams", WritingHandler.CreateExamHandler);
        app.MapPut("/exams/{examId:guid}", WritingHandler.UpdateExamHandler);
        app.MapDelete("/exams/{examId:guid}", WritingHandler.DeleteExamHandler);

    }
}
