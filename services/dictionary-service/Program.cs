using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.EntityFrameworkCore;
using dictionary_service.Features;
using dictionary_service.Features.Helper;
using dictionary_service.Features.Service;
using dictionary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ── ServiceDefaults ──────────────────────────────────────────────────────
builder.AddServiceDefaults();

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
builder.AddNpgsqlDbContext<DictionaryDbContext>("dictionary-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new Microsoft.EntityFrameworkCore.Storage.NonRetryingExecutionStrategy(deps)));
});

var connectionString = builder.Configuration.GetConnectionString("dictionary-db")
    ?? $"Host=localhost;Port=5443;Database=dictionary-db;Username=dictionary;Password=dictionary";

builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "dictionary-db", failureStatus: Microsoft.Extensions.Diagnostics.HealthChecks.HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" });

// ── Services ─────────────────────────────────────────────────────────────
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
        await context.Database.ExecuteSqlRawAsync(
            "CREATE EXTENSION IF NOT EXISTS pg_trgm; CREATE INDEX IF NOT EXISTS ix_dictionary_wordnorm_trgm ON dictionary USING GIN (\"WordNorm\" gin_trgm_ops);");
    }
}

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.MapDictionaryEndpoint();
app.Run();

public partial class Program { }