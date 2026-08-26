using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using ExamService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using ExamService.Features.Exams.AdminEndpoint;
using ExamService.Features.Seeders;

var builder = WebApplication.CreateBuilder(args);

// ── Aspire service defaults (OTel, discovery, resilience, /health, /alive) ──
builder.AddServiceDefaults();

// ── Shared bootstrap (JWT, CORS, Swagger) ────────────────────────────────────
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Exam Service");

// Exam-service-specific authorization policies (User/Admin/ExamRead/ExamManage/AdminPolicy).
// Must be registered before any endpoint calls .RequireAuthorization(...).
builder.Services.AddExamAuthorization();

// EnvelopeValidator is stateless; singleton avoids per-request allocation of JsonSerializerOptions.
builder.Services.AddSingleton<ExamService.Features.Validation.EnvelopeValidator>();

// gRPC: register the server pipeline so MapGrpcService<T>() can bind the
// generated proto base class implementations.
builder.Services.AddGrpc();
// ── Database (EF Core + Npgsql via Aspire) ───────────────────────────────────
// Npgsql 8+ requires explicit opt-in for jsonb → CLR type mapping (Dictionary, List, etc.)
builder.AddNpgsqlDbContext<ExamDbContext>("exam-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(o => o.ConfigureDataSource(ds => ds.EnableDynamicJson()));
});

var app = builder.Build();

// Apply pending EF migrations on startup so the seeder (below) and HTTP
// endpoints can rely on the schema being present.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    await db.Database.MigrateAsync();
}

app.MapDefaultEndpoints();

app.MapGrpcService<ExamService.Features.Exams.InternalEndpoint.InternalExamGrpcService>();

app.MapAdminQuestionUpsert();

// Seed JSON envelopes from deploy/seeds/exams/*.json (idempotent, no-op if rows exist or dir is missing).
await app.SeedExamJsonAsync();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");

app.Run();

public partial class Program { }