using MassTransit;
using email_service.Contracts;
using email_service.Features;
using email_service.Features.Service;
using email_service.Features.Worker;
using Shared.ExamDto.Contracts.Auth_Email;

var builder = WebApplication.CreateBuilder(args);

// ── Shared bootstrap ────────────────────────────────────────────────────
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Email Service");
builder.Services.AddSmtpConfig(key => Environment.GetEnvironmentVariable(key));

// ── RabbitMQ ─────────────────────────────────────────────────────────────
var rabbitConfig = LangfensBootstrapExtensions.BuildRabbitMqConfig(
    key => Environment.GetEnvironmentVariable(key));
builder.Services.AddSingleton(rabbitConfig);
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<TestpingConsumer>();
    cfg.AddConsumer<UserRegisteredSendOtpConsumer>();

    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.ConfigureRabbitMqHost(rabbitConfig);

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
