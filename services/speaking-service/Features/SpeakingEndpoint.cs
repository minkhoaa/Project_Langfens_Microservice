using speaking_service.Features.Handler;
using speaking_service.Features.Services;

namespace speaking_service.Features;

public static class SpeakingEndpoint
{
    public static void MapSpeakingEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/speaking");
        app.MapPost("/transcript", WhisperHandler.TranscriptHandler)
            .DisableAntiforgery();
        
    }

    public static void MapWebsocketSpeaking(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/ws/speaking");
        app.Map("/transcript", WhisperHandler.HandleWebsocketAsync);
    }
}