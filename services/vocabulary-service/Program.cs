using System.Net;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using vocabulary_service.Application;
using vocabulary_service.Features;
using vocabulary_service.Features.Admin;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddVocabularyAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Vocabulary Service");

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__VOCABULARY")
    ?? "Host=vocabulary-database;Port=5432;Database=vocabulary-db;Username=vocabulary;Password=vocabulary";
builder.Services.AddDbContext<VocabularyDbContext>(o => o.UseNpgsql(connectionString));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.ConfigureRabbitMqHost(rabbitConfig);
    });
});

// ── AI client (Azure OpenAI) ─────────────────────────────────────────────
var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT");
var azureApiKey = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY");
var azureDeployment = Environment.GetEnvironmentVariable("AZURE_OPENAI__DEPLOYMENT") ?? "gpt-4o-mini";

if (!string.IsNullOrWhiteSpace(azureEndpoint) && !string.IsNullOrWhiteSpace(azureApiKey))
{
    builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
        model: azureDeployment,
        credential: new System.ClientModel.ApiKeyCredential(azureApiKey),
        options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(azureEndpoint) }
    ));
    Console.WriteLine($"[INFO] Azure OpenAI enabled with deployment: {azureDeployment}");
}
else
{
    builder.Services.AddSingleton<OpenAI.Chat.ChatClient>(_ => null!);
    Console.WriteLine("[WARN] Azure OpenAI not configured – AI enrichment disabled");
}

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPublicService, PublicService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IAiEnrichmentService, AiEnrichmentService>();
builder.Services.AddScoped<IVocabularyExtractionService, VocabularyExtractionService>();

// ── App ───────────────────────────────────────────────────────────────────
var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
    if (db.Database.IsRelational())
        await db.Database.MigrateAsync();
}

app.MapPublicVocabularyEndpoints();
app.MapUserVocabularyEndpoints();
app.Run();

public partial class Program { }
