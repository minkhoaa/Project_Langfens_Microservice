using chatbot_service.Features.Handler;

namespace chatbot_service.Features;

public static class ChatbotEndpoint
{
    public static void MapChatbotEndpoint(this IEndpointRouteBuilder route)
    {
        var app = route.MapGroup("/api/ielts");

        app.MapPost("/chat", ChatbotHandler.ChatHandler);
        app.MapPost("/chat-stream", ChatbotHandler.ChatStreamHandler);
    }
}
