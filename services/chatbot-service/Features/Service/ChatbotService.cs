using System.Text;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using chatbot_service.Contracts;

namespace chatbot_service.Features.Service;

public interface IChatbotService
{
    Task<IResult> ChatAsync(ChatRequest request, CancellationToken token);
    Task StreamChatAsync(ChatRequest request, CancellationToken token);
}

public class ChatbotService : IChatbotService
{
    private const string SystemPrompt =
        "You are an IELTS tutor. You can explain in Vietnamese or English depending on the user's message. Answer clearly and concisely.";

    private readonly HttpClient _client;
    private readonly IHttpContextAccessor _contextAccessor;

    public ChatbotService(IHttpClientFactory factory, IHttpContextAccessor contextAccessor)
    {
        _client = factory.CreateClient("ollama");
        _contextAccessor = contextAccessor;
    }

    public async Task<IResult> ChatAsync(ChatRequest request, CancellationToken token)
    {
        var payload = new
        {
            model = "qwen2.5:1.5b-instruct",
            messages = BuildMessages(request),
            stream = false
        };

        var response = await _client.PostAsJsonAsync("/api/chat", payload, token);
        response.EnsureSuccessStatusCode();

        var ollamaResponse = await response.Content.ReadFromJsonAsync<OllamaChatResponse>(cancellationToken: token);
        var content = ollamaResponse?.Message?.Content ?? string.Empty;

        return Results.Ok(new ChatResponse(content));
    }

    public async Task StreamChatAsync(ChatRequest request, CancellationToken token)
    {
        var httpContext = _contextAccessor.HttpContext
                           ?? throw new InvalidOperationException("HttpContext is not available.");

        httpContext.Response.StatusCode = StatusCodes.Status200OK;
        httpContext.Response.ContentType = "text/plain; charset=utf-8";

        var payload = new
        {
            model = "qwen2.5:1.5b-instruct",
            stream = true,
            messages = BuildMessages(request)
        };

        using var requestMessage = new HttpRequestMessage(HttpMethod.Post, "/api/chat")
        {
            Content = JsonContent.Create(payload)
        };

        using var ollamaResponse = await _client.SendAsync(
            requestMessage,
            HttpCompletionOption.ResponseHeadersRead,
            token
        );

        ollamaResponse.EnsureSuccessStatusCode();

        await using var responseStream = await ollamaResponse.Content.ReadAsStreamAsync(token);
        using var reader = new StreamReader(responseStream);

        while (!token.IsCancellationRequested && !httpContext.RequestAborted.IsCancellationRequested)
        {
            var line = await reader.ReadLineAsync();

            if (line is null)
            {
                break;
            }

            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            OllamaStreamChunk? chunk;
            try
            {
                chunk = JsonSerializer.Deserialize<OllamaStreamChunk>(line);
            }
            catch
            {
                continue;
            }

            if (chunk is null)
            {
                continue;
            }

            if (chunk.Done)
            {
                break;
            }

            var text = chunk.Message?.Content;
            if (string.IsNullOrEmpty(text))
            {
                continue;
            }

            var buffer = Encoding.UTF8.GetBytes(text);
            await httpContext.Response.Body.WriteAsync(buffer, 0, buffer.Length, token);
            await httpContext.Response.Body.FlushAsync(token);
        }
    }

    private static IEnumerable<object> BuildMessages(ChatRequest request)
    {
        yield return new { role = "system", content = "" };

        var messages = request.Messages ?? new List<ChatMessage>();
        foreach (var message in messages)
        {
            yield return new
            {
                role = message.Role.ToLowerInvariant(),
                content = message.Content
            };
        }
    }
}

internal record OllamaMessage(
    [property: JsonPropertyName("role")] string Role,
    [property: JsonPropertyName("content")] string Content
);

internal record OllamaChatResponse(
    [property: JsonPropertyName("message")] OllamaMessage? Message
);

internal record OllamaStreamChunk(
    [property: JsonPropertyName("message")] OllamaMessage? Message,
    [property: JsonPropertyName("done")] bool Done
);
