using System.Net;
using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using MassTransit;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shared.Bootstrap;
using Shared.Security.Scopes;
using System.Text.Json;
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
builder.AddNpgsqlDbContext<VocabularyDbContext>("vocabulary-db");

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.Host(rabbitConfig.Host, rabbitConfig.Port, rabbitConfig.VirtualHost, h =>
        {
            h.Username(rabbitConfig.Username);
            h.Password(rabbitConfig.Password);
            if (rabbitConfig.UseSsl)
                h.UseSsl(k => k.Protocol = System.Security.Authentication.SslProtocols.Tls12);
        });
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

// ── Health checks ────────────────────────────────────────────────────────
builder.Services.AddHealthChecks()
    .AddNpgSql(
        connectionString: builder.Configuration.GetConnectionString("vocabulary-db")!,
        name: "vocabulary-db",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "postgresql" });

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

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds
            })
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }));
    }
});

app.MapPublicVocabularyEndpoints();
app.MapUserVocabularyEndpoints();
app.Run();

public partial class Program { }