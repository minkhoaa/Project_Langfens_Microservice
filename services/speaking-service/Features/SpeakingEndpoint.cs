using speaking_service.Contracts;
using speaking_service.Features.Handler;
using Shared.Security.Roles;

namespace speaking_service.Features;

public static class SpeakingEndpoint
{
    public static void MapSpeakingEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/speaking");
        app.MapPost("/transcript", WhisperHandler.TranscriptHandler).DisableAntiforgery();
        app.MapPost("/grade", SpeakingHandler.SubmitHandler)
            .Accepts<SpeakingSubmitForm>("multipart/form-data")
            .DisableAntiforgery();
        app.MapGet("/exams", SpeakingHandler.GetExamListHandler);
        app.MapGet("/exams/{examId:guid}", SpeakingHandler.GetExamHandler);
        app.MapGet("/history", SpeakingHandler.GetHistoryHandler).RequireAuthorization(Roles.User);
        app.MapPost("/start/{examId}", SpeakingHandler.StartSpeakingExamHandler);

    }

    public static void MapWebsocketSpeaking(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/ws/speaking");
        app.Map("/transcript", WhisperHandler.HandleWebsocketAsync);
    }

    public static void MapSpeakingAdminEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/admin/speaking");
        app.MapGet("/exams", SpeakingHandler.GetAdminExamsHandler).RequireAuthorization(Roles.Admin);
        app.MapPost("/create", SpeakingHandler.CreateExamHandler);
        app.MapPost("/exams", SpeakingHandler.CreateExamHandler);
        app.MapPut("/exams/{examId:guid}", SpeakingHandler.UpdateExamHandler);
        app.MapDelete("/exams/{examId:guid}", SpeakingHandler.DeleteExamHandler);
    }
}
