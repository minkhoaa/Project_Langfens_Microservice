using System.Net.Http.Headers;
using Aspire.Npgsql;
using MassTransit;
using RabbitMQ.Client;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shared.Security.Claims;
using Shared.Security.Scopes;
using writing_service.Contracts;
using writing_service.Features;
using writing_service.Features.Helper;
using writing_service.Features.RabbitMq;
using writing_service.Features.Service.Admin;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Configuration;
using writing_service.Infrastructure.Persistence;

DotNetEnv.Env.Load();
var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults();

static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddWritingAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Writing Service");
builder.Services.AddHttpContextAccessor();

// ── Database ────────────────────────────────────────────────────────
// Register connection string in Aspire config so AppHost can inject it
var writingDbConnString = EnvOrDefault("CONNECTIONSTRING__WRITING",
    "Host=writing-database;Port=5432;Database=writing-db;Username=writing;Password=writing");
builder.Configuration.GetSection("ConnectionStrings")["writing-db"] = writingDbConnString;

// Add NpgsqlDataSource via Aspire (singleton, matches original behavior)
builder.AddNpgsqlDataSource("writing-db");

// Also register NpgsqlDataSource as singleton for direct use (e.g., raw queries)
var npgsqlDataSource = new Npgsql.NpgsqlDataSourceBuilder(writingDbConnString).Build();
builder.Services.AddSingleton(npgsqlDataSource);

// DbContext still uses the singleton NpgsqlDataSource
builder.Services.AddDbContext<WritingDbContext>(o =>
    o.UseNpgsql(npgsqlDataSource, npg =>
        npg.MigrationsAssembly(typeof(WritingDbContext).Assembly.GetName().Name)));

// ── AI client ───────────────────────────────────────────────────────
// Default to localhost so `dotnet run` works out of the box. In
// compose/Aspire, AI_SERVICE_URL is set to the internal service name
// (e.g. http://ai-service:8080 — ai-service container listens on 8080
// internally, mapped to host 8092).
var aiServiceUrl = EnvOrDefault("AI_SERVICE_URL", "http://localhost:8092");
var aiClient = new HttpClient {
    BaseAddress = new Uri(aiServiceUrl),
    Timeout = TimeSpan.FromMinutes(10)
};

builder.Services.AddSingleton<IAiCompareClient>(sp => 
    new AiCompareClient(aiClient, 
        sp.GetRequiredService<ILogger<AiCompareClient>>(),
        sp.GetRequiredKeyedService<CircuitBreaker>("compare")));

builder.Services.AddKeyedSingleton<CircuitBreaker>("grader");
builder.Services.AddKeyedSingleton<CircuitBreaker>("compare");

builder.Services.AddSingleton<IWritingGrader>(sp => 
    new AiWritingGrader(aiClient, 
        sp.GetRequiredService<ILogger<AiWritingGrader>>(),
        sp.GetRequiredKeyedService<CircuitBreaker>("grader")));

// ── Services ────────────────────────────────────────────────────────
builder.Services.AddScoped<IWritingService, WritingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IUserContext, UserContext>();

// ── RabbitMQ ───────────────────────────────────────────────────────
var rabbitConfig = new RabbitMqConfig
{
    Host = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ?? "localhost",
    Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var port) ? port : (ushort)5672,
    VirtualHost = Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/",
    Username = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ?? throw new InvalidOperationException("RABBITMQ__USERNAME is required"),
    Password = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ?? throw new InvalidOperationException("RABBITMQ__PASSWORD is required"),
    UseSsl = bool.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__USESSL"), out var ssl) && ssl,
};

builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<WritingSubmittedConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(rabbitConfig.Host, rabbitConfig.Port, rabbitConfig.VirtualHost, h =>
        {
            h.Username(rabbitConfig.Username);
            h.Password(rabbitConfig.Password);
            if (rabbitConfig.UseSsl)
                h.UseSsl(k => k.Protocol = System.Security.Authentication.SslProtocols.Tls12);
        });
        bus.ConfigureEndpoints(ctx);
    });
});

// ── Health checks ────────────────────────────────────────────────────
builder.Services.AddHealthChecks()
    .AddNpgSql(
        connectionString: writingDbConnString,
        name: "writing-db",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "postgresql" });

// ── App ───────────────────────────────────────────────────────────
var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<WritingDbContext>();
    await db.Database.MigrateAsync();
}
app.UseSwagger();
app.UseSwaggerUI();
app.MapDefaultEndpoints();
app.UseAuthentication();
app.UseAuthorization();
app.MapWritingEndpoint();
app.MapWritingAdminEndpoint();

app.Run();

public partial class Program { }