using System.Security.Authentication;
using email_service.Contracts;
using email_service.Features;
using email_service.Features.Service;
using email_service.Features.Worker;
using MassTransit;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts.Auth_Email;

var builder = WebApplication.CreateBuilder(args);

static string EnvOrDefault(string key, string fallback) => Environment.GetEnvironmentVariable(key) ?? fallback;

builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

var smtpHost   = Environment.GetEnvironmentVariable("SMTP__HOST")   
                 ?? "smtp.gmail.com";
var smtpPort   = int.Parse(Environment.GetEnvironmentVariable("SMTP__PORT") 
                           ?? "587");
var smtpUser   = Environment.GetEnvironmentVariable("SMTP__USER")   
                 ?? "";
var smtpPass   = Environment.GetEnvironmentVariable("SMTP__PASS")   
                 ?? "";
var smtpFrom   = Environment.GetEnvironmentVariable("SMTP__FROM")   
                 ?? "No-Reply <no-reply@example.com>";
var smtpBrand  = Environment.GetEnvironmentVariable("SMTP__BRAND")  
                 ?? "Langfens English";
var smtpSupport= Environment.GetEnvironmentVariable("SMTP__SUPPORT")
                 ?? "support@langfens-english.com";
var verifyTpl  = Environment.GetEnvironmentVariable("SMTP__VERIFYURLTEMPLATE") 
                 ?? "http://auth-service:8080/api/auth/verify";
var redirectUrl = Environment.GetEnvironmentVariable("SMTP__REDIRECTURL") 
                  ?? "http://localhost:8080/api/auth/verify";
builder.Services.Configure<SmtpOptions>(o =>
{
    o.Host = smtpHost;
    o.Port = smtpPort;
    o.User = smtpUser;
    o.Pass = smtpPass;
    o.From = smtpFrom;
    o.Brand = smtpBrand;
    o.Support = smtpSupport;
    o.VerifyUrlTemplate = verifyTpl;
    o.RedirectUrl = redirectUrl;
});

var rabbitConfig = new RabbitMqConfig
{
    Host = EnvOrDefault("RABBITMQ__HOST", "localhost"),
    Username = EnvOrDefault("RABBITMQ__USERNAME", "guest"),
    Password = EnvOrDefault("RABBITMQ__PASSWORD", "guest"),
    VirtualHost = EnvOrDefault("RABBITMQ__VHOST", "/"),
    Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var parsedPort) ? parsedPort : (ushort)5672,
    UseSsl = bool.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__USESSL"), out var proSsl) && proSsl
};
builder.Services.AddSingleton<IOptions<RabbitMqConfig>>(Options.Create(rabbitConfig));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IEmailSender, EmailSender>();
builder.Services.AddHttpClient("email-confirm", (ctx, req) =>
{
    var options = ctx.GetRequiredService<IOptions<SmtpOptions>>().Value;
    req.Timeout = TimeSpan.FromSeconds(30);
});
builder.Services.AddMassTransit(configurator =>
{

    configurator.AddConsumer<TestpingConsumer>();
    configurator.AddConsumer<UserRegisteredSendOtpConsumer>();
    
    configurator.UsingRabbitMq((context, config) =>
    {
        config.Host(rabbitConfig.Host, rabbitConfig.Port ,rabbitConfig.VirtualHost, h =>
        {
            h.Username(rabbitConfig.Username);
            h.Password(rabbitConfig.Password);
            if (rabbitConfig.UseSsl)
            {
                h.UseSsl(a =>
                {
                    a.Protocol = SslProtocols.Tls12;
                });
            }
        });
        // Configure endpoints automatically for registered consumers.
        config.ReceiveEndpoint("email-testping", e => e.ConfigureConsumer<TestpingConsumer>(context));
        config.ReceiveEndpoint("user-registered-send-otp", e => e.ConfigureConsumer<UserRegisteredSendOtpConsumer>(context));
    });
});
var app = builder.Build();


app.UseCors("FE");

app.UseSwagger();
app.UseSwaggerUI();
app.MapPost("/send-otp", async (string email, string otp, IEmailSender mailer, CancellationToken token = default) =>
{
    await mailer.SendOtpAsync(email, otp, ttlSeconds: 300, token);
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
