using chatbot_service.Features;
using chatbot_service.Features.Service;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
var ollamaBaseUrl = Environment.GetEnvironmentVariable("OLLAMA_BASE_URL")
                    ?? builder.Configuration["OLLAMA_BASE_URL"]
                    ?? "http://localhost:11434";
builder.Services.AddHttpClient("ollama", client => client.BaseAddress = new Uri(ollamaBaseUrl));
builder.Services.AddHttpContextAccessor();

builder.Services.AddScoped<IChatbotService, ChatbotService>();


var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference();


app.MapGet("/healthz", () => Results.Ok("Oke"));
app.MapChatbotEndpoint();


app.Run();
