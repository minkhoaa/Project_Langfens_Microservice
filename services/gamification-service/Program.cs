using MassTransit;
using Microsoft.EntityFrameworkCore;
using gamification_service.Features;
using gamification_service.Features.Consumers;
using gamification_service.Infrastructure;
using gamification_service.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddGamificationAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Gamification Service");
builder.Services.AddHttpContextAccessor();

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__GAMIFICATION")
    ?? "Host=gamification-database;Port=5432;Database=gamification-db;Username=gamification;Password=gamification";
builder.Services.AddDbContext<GamificationDbContext>(o => o.UseNpgsql(connectionString));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<AttemptCompletedConsumer>();
    cfg.AddConsumer<CardReviewedConsumer>();
    cfg.AddConsumer<LessonCompletedConsumer>();
    cfg.AddConsumer<UserCreatedConsumer>();

    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.ConfigureRabbitMqHost(rabbitConfig);
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

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

app.MapGamificationEndpoints();
app.MapNotificationEndpoints();
app.Run();

public partial class Program { }
