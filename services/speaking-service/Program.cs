using System.Security.Authentication;
using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using DotNetEnv;
using MassTransit;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using speaking_service.Features;
using speaking_service.Features.Helper;
using speaking_service.Features.RabbitMq;
using speaking_service.Features.Services.Admin;
using speaking_service.Features.Services.Helper;
using speaking_service.Features.Services.User;
using speaking_service.Features.Storage;
using speaking_service.Infrastructure.Persistence;
using Whisper.net;
using Whisper.net.LibraryLoader;

Env.Load();
var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// ── Helpers ─────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddSpeakingAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Speaking Service");

// ── Kestrel: 50MB upload limit ───────────────────────────────────────────
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = 50 * 1024 * 1024;
});

// ── Cloudinary ───────────────────────────────────────────────────────────
builder.Services.AddSingleton<CloudinaryConfig>();
builder.Services.AddSingleton(sp =>
{
    var config = sp.GetRequiredService<CloudinaryConfig>();
    var account = new CloudinaryDotNet.Account
    {
        ApiSecret = config.ApiSecret,
        ApiKey = config.ApiKey,
        Cloud = config.CloudName
    };
    return new CloudinaryDotNet.Cloudinary(account) { Api = { Secure = true } };
});

// ── Database (Aspire) ─────────────────────────────────────────────────────
builder.AddNpgsqlDbContext<SpeakingDbContext>("speaking-db");

// ── RabbitMQ (Aspire MassTransit factory pattern) ─────────────────────────
var rabbitHost = EnvOrDefault("RABBITMQ__HOST", "localhost");
var rabbitUser = EnvOrDefault("RABBITMQ__USERNAME", "guest");
var rabbitPass = EnvOrDefault("RABBITMQ__PASSWORD", "guest");
var rabbitVhost = EnvOrDefault("RABBITMQ__VHOST", "/");
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var rp) ? rp : (ushort)5672;

// Get connection string before adding health checks
var connectionString = builder.Configuration.GetConnectionString("speaking-db")
    ?? $"Host=localhost;Port=5432;Database=speaking-db;Username=speaking;Password=speaking";

var amqpUri = new Uri($"amqp://{rabbitUser}:{rabbitPass}@{rabbitHost}:{rabbitPort}/{rabbitVhost}");

builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "speaking-db", failureStatus: HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddRabbitMQ(o => o.ConnectionUri = amqpUri, name: "rabbitmq", failureStatus: HealthStatus.Unhealthy, tags: new[] { "messaging" });

builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<SpeakingGradingConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(new Uri($"rabbitmq://{rabbitHost}:{rabbitPort}/{rabbitVhost}"), h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
        });
        bus.ConfigureEndpoints(ctx);
    });
});

// ── Auth + context ───────────────────────────────────────────────────────
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddSingleton<ICloudinaryService, CloudinaryService>();
builder.Services.AddScoped<IWhisperService, WhisperService>();
builder.Services.AddScoped<ISpeakingService, SpeakingService>();
builder.Services.AddScoped<IAdminService, AdminService>();

// ── AI clients ───────────────────────────────────────────────────────────
// AZURE_OPENAI removed — grading delegated to ai-service via HttpClient

// ── Whisper ───────────────────────────────────────────────────────────────
RuntimeOptions.RuntimeLibraryOrder = [RuntimeLibrary.Cuda, RuntimeLibrary.Cpu, RuntimeLibrary.CpuNoAvx];
var whisperModelPath = await WhisperModelHelper.EnsureModelDownloadedAsync();
builder.Services.AddSingleton<WhisperFactory>(_ => WhisperFactory.FromPath(whisperModelPath));
builder.Services.AddScoped<WhisperProcessor>(sp =>
    sp.GetRequiredService<WhisperFactory>()
      .CreateBuilder()
      .WithLanguage("en")
      .Build());
builder.Services.AddHttpClient<IAudioDownloader, AudioDownloader>();
var aiServiceUrl = EnvOrDefault("AI_SERVICE_URL", "http://ai-service:8080");
var aiClient = new HttpClient {
    BaseAddress = new Uri(aiServiceUrl),
    Timeout = TimeSpan.FromMinutes(10)
};
builder.Services.AddSingleton<ISpeakingGrader>(sp => 
    new AiSpeakingGrader(aiClient, sp.GetRequiredService<ILogger<AiSpeakingGrader>>()));

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SpeakingDbContext>();
    if (db.Database.IsRelational())
    {
        var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
        Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
        await db.Database.MigrateAsync();
    }
}

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapSpeakingEndpoint();
app.MapWebsocketSpeaking();
app.MapSpeakingAdminEndpoint();
app.MapUploadEndpoint();

app.Run();

public partial class Program { }