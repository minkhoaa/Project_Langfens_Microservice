using System.ComponentModel.Design;
using dictionary_service.Features;
using dictionary_service.Features.Service;
using dictionary_service.Infrastructure.Persistence;
using Elastic.Clients.Elasticsearch;
using Microsoft.EntityFrameworkCore;
using IDictionaryService = dictionary_service.Features.Service.IDictionaryService;

var builder = WebApplication.CreateBuilder(args);

static string EnvOrDefault(string key, string fallback) => Environment.GetEnvironmentVariable(key) ?? fallback;

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var connectionString = EnvOrDefault("CONNECTIONSTRING__DICTIONARY",
    "Host=dictionary-database;Port=5432;Database=dictionary-db;Username=dictionary;Password=dictionary");
builder.Services.AddDbContext<DictionaryDbContext>(option => option.UseNpgsql(connectionString));
builder.Services.AddSingleton(k =>
{
    var url = EnvOrDefault("ELASTICSEARCH__URL", "http://elasticsearch:9200");
    return new ElasticsearchClient(new ElasticsearchClientSettings(new Uri(url)));
});
builder.Services.AddScoped<ElasticIndexer>();
builder.Services.AddScoped<IDictionaryService, DictionaryService>();
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
