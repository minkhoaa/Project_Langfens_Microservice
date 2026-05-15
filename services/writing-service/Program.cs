using System.Net.Http.Headers;
using Aspire.Npgsql;
using MassTransit;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shared.Security.Claims;
using Shared.Security.Scopes;
using System.Text.Json;
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
builder.Services.AddHttpClient<IAiCompareClient, AiCompareClient>(client =>
{
    client.BaseAddress = new Uri(EnvOrDefault("AI_SERVICE_URL", "http://ai-service:8080"));
    client.Timeout = TimeSpan.FromSeconds(90);
});
builder.Services.AddKeyedSingleton<CircuitBreaker>("grader");
builder.Services.AddKeyedSingleton<CircuitBreaker>("compare");
builder.Services.AddHttpClient<IWritingGrader, AiWritingGrader>(client =>
{
    client.BaseAddress = new Uri(EnvOrDefault("AI_SERVICE_URL", "http://ai-service:8080"));
    client.Timeout = TimeSpan.FromSeconds(90);
});

// ── Services ────────────────────────────────────────────────────────
builder.Services.AddScoped<IWritingService, WritingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IUserContext, UserContext>();

// ── RabbitMQ ───────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
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
app.UseAuthentication();
app.UseAuthorization();
app.MapWritingEndpoint();
app.MapWritingAdminEndpoint();

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds
            })
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }));
    }
});

app.Run();

public partial class Program { }