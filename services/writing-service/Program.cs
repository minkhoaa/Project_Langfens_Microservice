using System.Net.Http.Headers;
using DotNetEnv;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.Security.Claims;
using Shared.Security.Scopes;
using writing_service.Contracts;
using writing_service.Features;
using writing_service.Features.Helper;
using writing_service.Features.RabbitMq;
using writing_service.Features.Service.Admin;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Configuration;
using writing_service.Infrastructure.Persistence;

Env.Load();
var builder = WebApplication.CreateBuilder(args);

static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddWritingAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Writing Service");
builder.Services.AddHttpContextAccessor();

// ── Database ────────────────────────────────────────────────────────
var writingConnectionString = EnvOrDefault("CONNECTIONSTRING__WRITING",
    "Host=writing-database;Port=5432;Database=writing-db;Username=writing;Password=writing");
if (string.IsNullOrWhiteSpace(writingConnectionString))
    throw new Exception("CONNECTIONSTRING__WRITING is required");
var dsb = new Npgsql.NpgsqlDataSourceBuilder(writingConnectionString);
dsb.EnableDynamicJson();
builder.Services.AddDbContext<WritingDbContext>(o => o.UseNpgsql(dsb.Build()));

// ── AI client ───────────────────────────────────────────────────────
builder.Services.AddHttpClient<IAiCompareClient, AiCompareClient>(client =>
{
    client.BaseAddress = new Uri(EnvOrDefault("AI_SERVICE_URL", "http://ai-service:8080"));
    client.Timeout = TimeSpan.FromSeconds(90);
});
builder.Services.AddSingleton<CircuitBreaker>();
builder.Services.AddSingleton<IWritingGrader, WritingGrader>();

// ── Services ────────────────────────────────────────────────────────
builder.Services.AddScoped<IWritingService, WritingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IUserContext, UserContext>();

// ── RabbitMQ ───────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<WritingSubmittedConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.ConfigureRabbitMqHost(rabbitConfig);
        bus.ConfigureEndpoints(ctx);
    });
});

// ── Azure OpenAI ────────────────────────────────────────────────────
var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT")
    ?? throw new Exception("AZURE_OPENAI__ENDPOINT is required");
var azureApiKey   = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY")
    ?? throw new Exception("AZURE_OPENAI__APIKEY is required");
var azureDeployment = EnvOrDefault("AZURE_OPENAI__DEPLOYMENT", "gpt-4o-mini");
builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
    model: azureDeployment,
    credential: new System.ClientModel.ApiKeyCredential(azureApiKey),
    options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(azureEndpoint) }
));

// ── App ───────────────────────────────────────────────────────────
var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<WritingDbContext>();
    await db.Database.MigrateAsync();
}
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapWritingEndpoint();
app.MapWritingAdminEndpoint();
app.Run();
