using Elastic.Clients.Elasticsearch;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.EntityFrameworkCore;
using dictionary_service.Features;
using dictionary_service.Features.Helper;
using dictionary_service.Features.Service;
using dictionary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

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

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__DICTIONARY")
    ?? "Host=dictionary-database;Port=5432;Database=dictionary-db;Username=dictionary;Password=dictionary";
builder.Services.AddDbContext<DictionaryDbContext>(o => o.UseNpgsql(connectionString));

// ── Elasticsearch ────────────────────────────────────────────────────────
var esUrl = Environment.GetEnvironmentVariable("ELASTICSEARCH__URL") ?? "http://elasticsearch:9200";
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
    await context.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();
app.MapDictionaryEndpoint();
app.Run();

public partial class Program { }
