using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using HealthChecks.RabbitMQ;
using MassTransit;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using gamification_service.Features;
using gamification_service.Features.Consumers;
using gamification_service.Infrastructure;
using gamification_service.Infrastructure.Persistence;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddGamificationAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Gamification Service");
builder.Services.AddHttpContextAccessor();

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ?? throw new InvalidOperationException("RABBITMQ__USERNAME is required");
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ?? throw new InvalidOperationException("RABBITMQ__PASSWORD is required");
var rabbitVhost = Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/";
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var rp) ? rp : (ushort)5672;

// Get connection string before adding health checks
var connectionString = builder.Configuration.GetConnectionString("gamification-db") ?? throw new InvalidOperationException("gamification-db connection string is required");

var amqpUri = new Uri($"amqp://{rabbitUser}:{rabbitPass}@{rabbitHost}:{rabbitPort}/{rabbitVhost}");

builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "gamification-db", failureStatus: HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddRabbitMQ(o => o.ConnectionUri = amqpUri, name: "rabbitmq", failureStatus: HealthStatus.Unhealthy, tags: new[] { "messaging" });

// ── Database ─────────────────────────────────────────────────────────────
builder.AddNpgsqlDbContext<GamificationDbContext>("gamification-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new Microsoft.EntityFrameworkCore.Storage.NonRetryingExecutionStrategy(deps)));
});

// ── MassTransit (RabbitMQ) ────────────────────────────────────────────────
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<AttemptCompletedConsumer>();
    cfg.AddConsumer<CardReviewedConsumer>();
    cfg.AddConsumer<LessonCompletedConsumer>();
    cfg.AddConsumer<UserCreatedConsumer>();

    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(new Uri($"rabbitmq://{rabbitHost}:{rabbitPort}/{rabbitVhost}"), h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
        });
        bus.ConfigureEndpoints(ctx);
    });
});

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddScoped<IGamificationService, GamificationService>();
builder.Services.AddScoped<INotificationService, NotificationService>();

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<GamificationDbContext>();
    if (db.Database.IsRelational())
        await db.Database.MigrateAsync();
}

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

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapGamificationEndpoints();
app.MapNotificationEndpoints();
app.Run();

public partial class Program { }
