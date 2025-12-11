using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
var ollamaBaseUrl = Environment.GetEnvironmentVariable("OLLAMA_BASE_URL")
                    ?? builder.Configuration["OLLAMA_BASE_URL"]
                    ?? "http://localhost:11434";
builder.Services.AddHttpClient("ollama", client => client.BaseAddress = new Uri(ollamaBaseUrl));
var app = builder.Build();

// Configure the HTTP request pipeline.

app.MapOpenApi();
app.MapScalarApiReference();


app.MapGet("/healthz", () => Results.Ok("Oke"));


// Endpoint test: chatbot IELTS
app.MapPost("/api/ielts/chat", async (ChatRequest request, IHttpClientFactory httpClientFactory) =>
{
    var client = httpClientFactory.CreateClient("ollama");

    // Thêm system prompt cho cố định: trợ lí IELTS
    var systemMessage = new
    {
        role = "system",
        content = "You are an IELTS tutor. You can explain in Vietnamese or English depending on the user's message. Answer clearly and concisely."
    };

    // Map messages từ client sang format Ollama
    var userMessages = request.Messages
        .Select(m => new
        {
            role = m.Role.ToLowerInvariant(), // "user" / "assistant"...
            content = m.Content
        });

    var payload = new
    {
        model = "qwen2.5:1.5b-instruct",
        messages = new[] { systemMessage }.Concat(userMessages),
        stream = false // keep response as a single JSON object; streaming sends multiple JSON chunks
    };

    var response = await client.PostAsJsonAsync("/api/chat", payload);
    response.EnsureSuccessStatusCode();

    var ollamaResponse = await response.Content.ReadFromJsonAsync<OllamaChatResponse>();

    var content = ollamaResponse?.Message.Content ?? string.Empty;

    return Results.Ok(new ChatResponse(content));
});
string BuildSystemPrompt() =>
    "You are an IELTS tutor. You can explain in Vietnamese or English depending on the user's message. Answer clearly and concisely.";

app.MapPost("/api/ielts/chat-stream", async (ChatRequest request, IHttpClientFactory httpClientFactory, HttpContext httpContext) =>
{
    var client = httpClientFactory.CreateClient("ollama");

    httpContext.Response.StatusCode = StatusCodes.Status200OK;
    httpContext.Response.ContentType = "text/plain; charset=utf-8";

    var systemMessage = new
    {
        role = "system",
        content = BuildSystemPrompt()
    };

    var userMessages = request.Messages
        .Select(m => new
        {
            role = m.Role.ToLowerInvariant(),
            content = m.Content
        });

    var payload = new
    {
        model = "qwen2.5:1.5b-instruct",
        stream = true,
        messages = new[] { systemMessage }.Concat(userMessages)
    };

    using var requestMessage = new HttpRequestMessage(HttpMethod.Post, "/api/chat")
    {
        Content = JsonContent.Create(payload)
    };

    using var ollamaResponse = await client.SendAsync(
        requestMessage,
        HttpCompletionOption.ResponseHeadersRead,
        httpContext.RequestAborted
    );

    ollamaResponse.EnsureSuccessStatusCode();

    await using var responseStream = await ollamaResponse.Content.ReadAsStreamAsync(httpContext.RequestAborted);
    using var reader = new StreamReader(responseStream);

    while (!reader.EndOfStream && !httpContext.RequestAborted.IsCancellationRequested)
    {
        var line = await reader.ReadLineAsync();

        if (string.IsNullOrWhiteSpace(line))
            continue;

        OllamaStreamChunk? chunk;
        try
        {
            chunk = JsonSerializer.Deserialize<OllamaStreamChunk>(line);
        }
        catch
        {
            // Nếu có dòng lạ (log, empty), bỏ qua
            continue;
        }

        if (chunk is null)
            continue;

        if (chunk.Done)
            break;

        var text = chunk.Message?.Content;
        if (!string.IsNullOrEmpty(text))
        {
            var buffer = Encoding.UTF8.GetBytes(text);
            await httpContext.Response.Body.WriteAsync(buffer, 0, buffer.Length, httpContext.RequestAborted);
            await httpContext.Response.Body.FlushAsync(httpContext.RequestAborted);
        }
    }
});


app.Run();

public record ChatMessage(string Content, string Role);

public record ChatRequest(List<ChatMessage> Messages);

// Response gửi ra cho client
public record ChatResponse(string Content);

// DTO map với response của Ollama
public record OllamaMessage(
    [property: JsonPropertyName("role")] string Role,
    [property: JsonPropertyName("content")] string Content
);

public record OllamaChatResponse(
    [property: JsonPropertyName("message")] OllamaMessage Message
);

// Chunk cho streaming
public record OllamaStreamChunk(
    [property: JsonPropertyName("message")] OllamaMessage? Message,
    [property: JsonPropertyName("done")] bool Done
);