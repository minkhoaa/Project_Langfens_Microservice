using Microsoft.EntityFrameworkCore;
using vocabulary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<CardDbContext>(option => option.UseNpgsql(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__VOCABULARY") ??
    builder.Configuration.GetConnectionString("Vocabulary_DB") ??
    "Host=localhost;Port=5437;Database=vocabulary-db;Username=vocabulary;Password=vocabulary"
));
var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<CardDbContext>();
    await db.Database.MigrateAsync();
}
app.Run();
