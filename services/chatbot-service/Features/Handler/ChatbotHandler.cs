using chatbot_service.Contracts;
using chatbot_service.Features.Service;

namespace chatbot_service.Features.Handler;

public static class ChatbotHandler
{
    public static Task<IResult> ChatHandler(ChatRequest request, CancellationToken token, IChatbotService service) =>
        service.ChatAsync(request, token);

    public static Task ChatStreamHandler(ChatRequest request, CancellationToken token, IChatbotService service) =>
        service.StreamChatAsync(request, token);
}
