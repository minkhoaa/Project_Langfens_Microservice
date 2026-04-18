using System.Security.Authentication;
using DotNetEnv;
using MassTransit;
using Microsoft.EntityFrameworkCore;
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

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__SPEAKING")
    ?? "Host=speaking-database;Port=5432;Database=speaking-db;Username=speaking;Password=speaking";
builder.Services.AddDbContext<SpeakingDbContext>(o => o.UseNpgsql(connectionString));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<SpeakingGradingConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.ConfigureRabbitMqHost(rabbitConfig);
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
var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT")
    ?? throw new InvalidOperationException("AZURE_OPENAI__ENDPOINT is required");
var azureApiKey = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY")
    ?? throw new InvalidOperationException("AZURE_OPENAI__APIKEY is required");
var azureDeployment = Environment.GetEnvironmentVariable("AZURE_OPENAI__DEPLOYMENT") ?? "gpt-4o-mini";

builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
    model: azureDeployment,
    credential: new System.ClientModel.ApiKeyCredential(azureApiKey),
    options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(azureEndpoint) }
));

// ── Whisper ───────────────────────────────────────────────────────────────
RuntimeOptions.RuntimeLibraryOrder = [RuntimeLibrary.Cuda, RuntimeLibrary.Cpu, RuntimeLibrary.CpuNoAvx];
var whisperModelPath = await WhisperModelHelper.EnsureModelDownloadedAsync();
builder.Services.AddSingleton<WhisperFactory>(_ => WhisperFactory.FromPath(whisperModelPath));
builder.Services.AddHttpClient<IAudioDownloader, AudioDownloader>();
builder.Services.AddSingleton<ISpeakingGrader, SpeakingGrader>();

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SpeakingDbContext>();
    await db.Database.MigrateAsync();
}

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
