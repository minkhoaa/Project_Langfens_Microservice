using exam_service.Features.Exams.AdminEndpoint;
using exam_service.Features.Exams.AdminEndpoint.ExamEndpoint;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using exam_service.Features.Exams.AdminEndpoint.SectionEndpoint;
using exam_service.Features.Exams.InternalEndpoint;
using exam_service.Features.Exams.PublicEndpoint;
using exam_service.Features.QuestionBank;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Npgsql.EntityFrameworkCore.PostgreSQL.Infrastructure.Internal;

var builder = WebApplication.CreateBuilder(args);

// ── Helpers ─────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap (JWT, Auth policies, CORS, Swagger) ────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddExamAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Exam Service");

// ── Database ───────────────────────────────────────────────────────────────
var connectionString = EnvOrDefault("CONNECTIONSTRING__EXAM",
    "Host=exam-database;Port=5432;Database=exam-db;Username=exam;Password=exam");
var datasourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
datasourceBuilder.EnableDynamicJson();
builder.Services.AddDbContextPool<ExamDbContext>(opts =>
    opts.UseNpgsql(datasourceBuilder.Build()));

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<IExamService, ExamService>();
builder.Services.AddScoped<IAdminExamService, AdminExamService>();
builder.Services.AddScoped<IAdminOptionService, AdminOptionService>();
builder.Services.AddScoped<IAdminSectionService, AdminSectionService>();
builder.Services.AddScoped<IInternalExamService, InternalExamService>();
builder.Services.AddScoped<IAdminQuestionService, AdminQuestionService>();
builder.Services.AddScoped<IQuestionBankService, QuestionBankService>();

// ── gRPC + HTTP ports ───────────────────────────────────────────────────
builder.ConfigureLangfensKestrel(httpPort: 8080, grpcPort: 8081);
builder.Services.AddGrpc();

// ── App ─────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
    if (db.Database.IsRelational())
    {
        var pending = (await db.Database.GetPendingMigrationsAsync()).ToList();
        Console.WriteLine($"[EF] Pending migrations: {pending.Count} => {string.Join(", ", pending)}");
        await db.Database.MigrateAsync();
    }
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

var grpcEndpoint = app.MapGrpcService<ExamInternalGrpcService>().AllowAnonymous();
if (!app.Environment.IsEnvironment("Testing"))
{
    grpcEndpoint.RequireHost($"*:{8081}");
}

app.MapPublicExamEndpoints();
app.MapAdminExamEndpoint();
app.MapAdminSectionEndpoint();
app.MapAdminQuestionEndpoint();
app.MapAdminOptionEndpoint();
app.MapInternalExamEndpoint();
app.MapQuestionBankEndpoints();
app.Run();

public partial class Program { }
