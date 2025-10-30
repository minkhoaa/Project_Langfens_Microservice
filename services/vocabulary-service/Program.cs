using Microsoft.EntityFrameworkCore;
using vocabulary_service.Features;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<VocabularyDbContext>(option => option.UseNpgsql(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__VOCABULARY") ??
    builder.Configuration.GetConnectionString("Vocabulary_DB") ??
    "Host=localhost;Port=5437;Database=vocabulary-db;Username=vocabulary;Password=vocabulary"
));
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPublicService, PublicService>();
var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
    await db.Database.MigrateAsync();
}
app.MapPublicVocabularyEndpoints();
app.MapUserVocabularyEndpoints(); 
app.Run();
