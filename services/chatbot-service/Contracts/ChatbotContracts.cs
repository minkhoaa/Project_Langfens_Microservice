namespace chatbot_service.Contracts;

public record ChatMessage(string Content, string Role);

public record ChatRequest(List<ChatMessage> Messages);

public record ChatResponse(string Content);
