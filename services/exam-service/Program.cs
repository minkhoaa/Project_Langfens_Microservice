using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using DotNetEnv;
using exam_service.Features.Exams.AdminEndpoint;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Features.QuestionBank;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Npgsql;
using Npgsql.EntityFrameworkCore.PostgreSQL.Infrastructure.Internal;

Env.Load();
var builder = WebApplication.CreateBuilder(args);

// ── Aspire service defaults (OTel, discovery, resilience, /health, /alive) ──
builder.AddServiceDefaults();

// ── Helpers ─────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap (JWT, Auth policies, CORS, Swagger) ────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddExamAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Exam Service");

// ── Database ───────────────────────────────────────────────────────────────
NpgsqlConnection.GlobalTypeMapper.EnableDynamicJson();
builder.AddNpgsqlDbContext<ExamDbContext>("exam-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new Microsoft.EntityFrameworkCore.Storage.NonRetryingExecutionStrategy(deps)));
});

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<IExamService, ExamService>();
builder.Services.AddScoped<IAdminExamService, AdminExamService>();
builder.Services.AddScoped<IAdminOptionService, AdminOptionService>();
builder.Services.AddScoped<IAdminSectionService, AdminSectionService>();
builder.Services.AddScoped<IInternalExamService, InternalExamService>();
builder.Services.AddScoped<IAdminQuestionService, AdminQuestionService>();
builder.Services.AddScoped<IQuestionBankService, QuestionBankService>();

// ── gRPC + HTTP ports ───────────────────────────────────────────────────
// Under Aspire, ASPNETCORE_URLS is injected and Kestrel binds to those endpoints.
// When Kestrel__GrpcPort is also allocated (via WithHttpEndpoint(name: "grpc")),
// add a dedicated HTTP/2-only listener. When running outside Aspire (compose path),
// use the explicit Kestrel__HttpPort / Kestrel__GrpcPort env vars.
var aspireUrls = Environment.GetEnvironmentVariable("ASPNETCORE_URLS");
if (!string.IsNullOrEmpty(aspireUrls))
{
    builder.WebHost.UseKestrelCore().ConfigureKestrel(o =>
    {
        // Always enable HTTP/1AndHttp2 on the Aspire-assigned endpoint so gRPC works
        foreach (var url in aspireUrls.Split(';', StringSplitOptions.RemoveEmptyEntries))
        {
            var uri = new Uri(url.Trim());
            o.ListenLocalhost(uri.Port, lo => lo.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http1AndHttp2);
        }
        // If Aspire allocated a dedicated gRPC port, add it as HTTP/2-only
        var grpcPortEnv = Environment.GetEnvironmentVariable("Kestrel__GrpcPort");
        if (int.TryParse(grpcPortEnv, out var grpcPort))
        {
            o.ListenAnyIP(grpcPort, lo => lo.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http2);
        }
    });
}
else
{
    var httpPort = int.TryParse(Environment.GetEnvironmentVariable("Kestrel__HttpPort"), out var hp) ? hp : 8080;
    var grpcPort = int.TryParse(Environment.GetEnvironmentVariable("Kestrel__GrpcPort"), out var gp) ? gp : 8081;
    builder.ConfigureLangfensKestrel(httpPort: httpPort, grpcPort: grpcPort);
}
builder.Services.AddGrpc();

builder.Services.AddHealthChecks()
    .AddNpgSql(
        connectionString: builder.Configuration.GetConnectionString("exam-db")!,
        name: "exam-db",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "postgresql" });

// ── App ─────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    if (db.Database.IsRelational())
    {
        var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
        Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");

        if (pending.Count > 0)
        {
            Console.WriteLine("[EF] Applying migrations...");
            await db.Database.MigrateAsync();
            Console.WriteLine("[EF] Migrations applied successfully");
        }
        else
        {
            Console.WriteLine("[EF] No pending migrations, checking WordList column...");

            try
            {
                await db.Database.ExecuteSqlRawAsync(@"
                    ALTER TABLE exam_questions ADD COLUMN IF NOT EXISTS ""WordList"" text[];
                ");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EF] WordList column check: {ex.Message}");
            }
        }
    }
    await exam_service.Data.ReadingSeeder.SeedReadingExamAsync(db);
    await exam_service.Data.ListeningSeeder.SeedListeningExamAsync(db);
}

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

// gRPC and HTTP/1.1 are multiplexed on the same Kestrel pipeline.
// Under Aspire, ASPNETCORE_URLS is dynamic; clients distinguish gRPC from HTTP via content-type.
// Under compose, ConfigureLangfensKestrel binds separate HTTP and HTTP/2 ports.
app.MapGrpcService<ExamInternalGrpcService>().AllowAnonymous();

app.MapPublicExamEndpoints();
app.MapAdminExamEndpoint();
app.MapAdminSectionEndpoint();
app.MapAdminQuestionEndpoint();
app.MapAdminOptionEndpoint();
app.MapInternalExamEndpoint();
app.MapQuestionBankEndpoints();
app.Run();

public partial class Program { }
