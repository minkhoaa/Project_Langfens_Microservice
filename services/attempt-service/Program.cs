using attempt_service.Features.Attempt;
using attempt_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddAttemptAuthorization();
builder.Services.AddLangfensJson();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Attempt Service");
builder.AddAttemptPersistence();
builder.Services.AddAttemptFlow();
builder.AddAttemptGrpcClient();

// Registers a typed HttpClient for the RAG explainer (Task 21). URL comes from
// AI_SERVICE_URL (Aspire injects the internal service URL; localhost:8092 is the
// dev fallback matching the Python ai-service container mapping).
var aiServiceUrl = Environment.GetEnvironmentVariable("AI_SERVICE_URL") ?? "http://localhost:8092";
builder.Services.AddHttpClient("ai-service", c => c.BaseAddress = new Uri(aiServiceUrl));

var app = builder.Build();

// Apply pending EF migrations on startup so HTTP endpoints can rely on the
// schema (attempts, attempt_results, attempt_questions) being present.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
    await db.Database.MigrateAsync();
}

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapStartAttempt();
app.MapGetAttempt();
app.MapAutosaveAttempt();
app.MapSubmitAttempt();
app.MapGetResult();
app.MapListAttempts();

app.Run();

public partial class Program { }
