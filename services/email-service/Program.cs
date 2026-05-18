using CommunityToolkit.Aspire.MassTransit.RabbitMQ;
using MassTransit;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using email_service.Contracts;
using email_service.Features;
using email_service.Features.Service;
using email_service.Features.Worker;
using Shared.ExamDto.Contracts.Auth_Email;

var builder = WebApplication.CreateBuilder(args);

// ── Aspire defaults ─────────────────────────────────────────────────────
builder.AddServiceDefaults();

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Email Service");
builder.Services.AddSmtpConfig(key => Environment.GetEnvironmentVariable(key));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ?? "guest";
var rabbitVhost = Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/";
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var rp) ? rp : (ushort)5672;

var amqpUri = new Uri($"amqp://{rabbitUser}:{rabbitPass}@{rabbitHost}:{rabbitPort}/{rabbitVhost}");

builder.Services.AddHealthChecks()
    .AddRabbitMQ(o => o.ConnectionUri = amqpUri, name: "rabbitmq", failureStatus: HealthStatus.Unhealthy, tags: new[] { "messaging" });

builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<TestpingConsumer>();
    cfg.AddConsumer<UserRegisteredSendOtpConsumer>();

    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(new Uri($"rabbitmq://{rabbitHost}:{rabbitPort}/{rabbitVhost}"), h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
        });

        bus.ReceiveEndpoint("email-testping", e => e.ConfigureConsumer<TestpingConsumer>(ctx));
        bus.ReceiveEndpoint("user-registered-send-otp", e => e.ConfigureConsumer<UserRegisteredSendOtpConsumer>(ctx));
    });
});

// ── Services ─────────────────────────────────────────────────────────────
builder.Services.AddHttpClient();
builder.Services.AddScoped<IEmailSender, EmailSender>();

// ── App ──────────────────────────────────────────────────────────────────
var app = builder.Build();

app.UseCors("FE");
app.UseSwagger();
app.UseSwaggerUI();

app.MapDefaultEndpoints();

app.MapPost("/send-otp", async (string email, string otp, IEmailSender mailer, CancellationToken ct = default) =>
{
    await mailer.SendOtpAsync(email, otp, ttlSeconds: 300, ct);
    return Results.Ok(new { success = true });
});

app.MapPost("/_test/push", async (string? text, IPublishEndpoint bus, CancellationToken ct) =>
{
    var msg = new TestPing(text ?? "Hello from API", DateTimeOffset.UtcNow);
    await bus.Publish(msg, ct);
    return Results.Ok(new { success = true, published = msg });
});

app.MapEmailEndpoint();
app.Run();

public partial class Program { }