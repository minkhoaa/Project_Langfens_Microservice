using System.Net;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using course_service.Features;
using course_service.Features.AdminEndpoint;
using course_service.Features.PublicEndpoint;
using course_service.Features.UserEndpoint;
using course_service.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensAuth(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddCourseAuthorization();
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Course Service");

// ── Database ─────────────────────────────────────────────────────────────
var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__COURSE")
    ?? "Host=course-database;Port=5432;Database=course-db;Username=course;Password=course";
builder.Services.AddDbContext<CourseDbContext>(o => o.UseNpgsql(connectionString));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.ConfigureRabbitMqHost(rabbitConfig);
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
    await context.Database.MigrateAsync();
}

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
