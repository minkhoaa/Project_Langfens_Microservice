using speaking_service.Contracts;
using speaking_service.Features.Handler;

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

    }

    public static void MapWebsocketSpeaking(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/ws/speaking");
        app.Map("/transcript", WhisperHandler.HandleWebsocketAsync);
    }
  
    public static void MapSpeakingAdminEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/admin/speaking");
        app.MapPost("/create", SpeakingHandler.CreateExamHandler);

    }
}
