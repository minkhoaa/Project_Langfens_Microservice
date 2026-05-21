using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using course_service.Features;
using course_service.Features.AdminEndpoint;
using course_service.Features.PublicEndpoint;
using course_service.Features.UserEndpoint;
using course_service.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddCourseAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Course Service");

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ?? "guest";
var rabbitVhost = Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/";
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var rp) ? rp : (ushort)5672;

var amqpUri = new Uri($"amqp://{rabbitUser}:{rabbitPass}@{rabbitHost}:{rabbitPort}/{rabbitVhost}");

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = builder.Configuration.GetConnectionString("course-db") ?? "Host=course-database;Port=5432;Database=course-db;Username=course;Password=course";

builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "course-db", failureStatus: HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddRabbitMQ(o => o.ConnectionUri = amqpUri, name: "rabbitmq", failureStatus: HealthStatus.Unhealthy, tags: new[] { "messaging" });

builder.AddNpgsqlDbContext<CourseDbContext>("course-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new Microsoft.EntityFrameworkCore.Storage.NonRetryingExecutionStrategy(deps)));
});

// ── MassTransit (RabbitMQ) ────────────────────────────────────────────────
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.Host(new Uri($"rabbitmq://{rabbitHost}:{rabbitPort}/{rabbitVhost}"), h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
        });
    });
});

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddScoped<IPublicEndpointService, PublicEndpointService>();
builder.Services.AddScoped<IUserEndpointService, UserEndpointService>();
builder.Services.AddScoped<IAdminEndpointService, AdminEndpointService>();

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<CourseDbContext>();
    if (context.Database.IsRelational())
        await context.Database.MigrateAsync();
}

app.MapDefaultEndpoints();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapCourseEndpoint();
app.MapLessonEndpoint();
app.MapAdminEndpoint();

app.Run();

public partial class Program { }