using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using Elastic.Clients.Elasticsearch;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using dictionary_service.Features;
using dictionary_service.Features.Helper;
using dictionary_service.Features.Service;
using dictionary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ── ServiceDefaults ──────────────────────────────────────────────────────
builder.AddServiceDefaults();

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

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.MapDictionaryEndpoint();
app.Run();

public partial class Program { }