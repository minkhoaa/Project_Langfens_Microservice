using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using Elastic.Clients.Elasticsearch;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using dictionary_service.Features;
using dictionary_service.Features.Helper;
using dictionary_service.Features.Service;
using dictionary_service.Infrastructure.Persistence;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// ── Helpers ─────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensSwagger("Dictionary Service");

// ── Kestrel: allow large uploads ────────────────────────────────────────
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = null;
});

// ── Form options for large imports ──────────────────────────────────────
builder.Services.Configure<FormOptions>(opt =>
{
    opt.MultipartBodyLengthLimit = long.MaxValue;
    opt.ValueLengthLimit = int.MaxValue;
    opt.MultipartHeadersLengthLimit = int.MaxValue;
});

// ── Database (Aspire) ─────────────────────────────────────────────────────
builder.AddNpgsqlDbContext<DictionaryDbContext>("dictionary-db");

// ── Elasticsearch ────────────────────────────────────────────────────────
var esUrl = EnvOrDefault("ELASTICSEARCH__URL", "http://elasticsearch:9200");

// Get connection string before adding health checks
var connectionString = builder.Configuration.GetConnectionString("dictionary-db")
    ?? $"Host=localhost;Port=5432;Database=dictionary-db;Username=dictionary;Password=dictionary";

builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "dictionary-db", failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddUrlGroup(new Uri(esUrl), name: "elasticsearch", failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy, tags: new[] { "search" });

builder.Services.AddSingleton(new ElasticsearchClient(
    new ElasticsearchClientSettings(new Uri(esUrl))));

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<ElasticIndexer>();
builder.Services.AddScoped<IDictionaryService, DictionaryService>();
builder.Services.AddSingleton<IEnViTranslator, NullEnViTranslator>();
builder.Services.AddSingleton<IDictionaryDtoMapper, DictionaryDtoMapper>();

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<DictionaryDbContext>();
    if (context.Database.IsRelational())
    {
        var pending = (await context.Database.GetPendingMigrationsAsync()).ToList();
        Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
        await context.Database.MigrateAsync();
    }
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

app.UseSwagger();
app.UseSwaggerUI();
app.MapDictionaryEndpoint();
app.Run();

public partial class Program { }