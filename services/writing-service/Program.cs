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
var npgsqlDataSource = dsb.Build();
builder.Services.AddSingleton(npgsqlDataSource);
builder.Services.AddDbContext<WritingDbContext>(o =>
    o.UseNpgsql(npgsqlDataSource, npg =>
        npg.MigrationsAssembly(typeof(WritingDbContext).Assembly.GetName().Name)));

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

// ── Grader LLM (OpenAI-compatible — defaults to Groq) ──────────────────
// Reads GRADER_LLM__ENDPOINT/_APIKEY/_MODEL. Falls back to legacy
// AZURE_OPENAI__ENDPOINT/_APIKEY/_DEPLOYMENT for one release with a
// deprecation warning so existing manifests keep booting.
static (string, string, string) ResolveGraderLlmConfig(ILogger logger)
{
    string? endpoint = Environment.GetEnvironmentVariable("GRADER_LLM__ENDPOINT");
    string? apiKey   = Environment.GetEnvironmentVariable("GRADER_LLM__APIKEY");
    string? model    = Environment.GetEnvironmentVariable("GRADER_LLM__MODEL");
    if (string.IsNullOrWhiteSpace(endpoint))
    {
        endpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT");
        if (!string.IsNullOrWhiteSpace(endpoint))
            logger.LogWarning(
                "Using deprecated AZURE_OPENAI__ENDPOINT; rename to GRADER_LLM__ENDPOINT");
    }
    if (string.IsNullOrWhiteSpace(apiKey))
    {
        apiKey = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY");
        if (!string.IsNullOrWhiteSpace(apiKey))
            logger.LogWarning(
                "Using deprecated AZURE_OPENAI__APIKEY; rename to GRADER_LLM__APIKEY");
    }
    model ??= Environment.GetEnvironmentVariable("AZURE_OPENAI__DEPLOYMENT")
             ?? "llama-3.3-70b-versatile";
    if (string.IsNullOrWhiteSpace(endpoint))
        throw new Exception("GRADER_LLM__ENDPOINT (or legacy AZURE_OPENAI__ENDPOINT) is required");
    if (string.IsNullOrWhiteSpace(apiKey))
        throw new Exception("GRADER_LLM__APIKEY (or legacy AZURE_OPENAI__APIKEY) is required");
    return (endpoint, apiKey, model);
}

var bootstrapLogger = LoggerFactory.Create(b => b.AddConsole()).CreateLogger("Bootstrap");
var (graderEndpoint, graderApiKey, graderModel) = ResolveGraderLlmConfig(bootstrapLogger);
builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
    model: graderModel,
    credential: new System.ClientModel.ApiKeyCredential(graderApiKey),
    options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(graderEndpoint) }
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
