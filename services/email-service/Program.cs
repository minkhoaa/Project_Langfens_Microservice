using System.Security.Authentication;
using email_service.Contracts;
using email_service.Features;
using email_service.Features.Service;
using email_service.Features.Worker;
using MassTransit;
using Microsoft.Extensions.Options;
using Shared.ExamDto.Contracts.Auth_Email;

var builder = WebApplication.CreateBuilder(args);

var smtpHost   = Environment.GetEnvironmentVariable("SMTP__HOST")   
                 ?? builder.Configuration["Smtp:Host"]   ?? "smtp.gmail.com";
var smtpPort   = int.Parse(Environment.GetEnvironmentVariable("SMTP__PORT") 
                           ?? (builder.Configuration["Smtp:Port"] ?? "587"));
var smtpUser   = Environment.GetEnvironmentVariable("SMTP__USER")   
                 ?? builder.Configuration["Smtp:User"]   ?? "";
var smtpPass   = Environment.GetEnvironmentVariable("SMTP__PASS")   
                 ?? builder.Configuration["Smtp:Pass"]   ?? "";
var smtpFrom   = Environment.GetEnvironmentVariable("SMTP__FROM")   
                 ?? builder.Configuration["Smtp:From"]   ?? "No-Reply <no-reply@example.com>";
var smtpBrand  = Environment.GetEnvironmentVariable("SMTP__BRAND")  
                 ?? builder.Configuration["Smtp:Brand"]  ?? "Langfens English";
var smtpSupport= Environment.GetEnvironmentVariable("SMTP__SUPPORT")
                 ?? builder.Configuration["Smtp:Support"]?? "support@langfens-english.com";
var verifyTpl  = Environment.GetEnvironmentVariable("SMTP__VERIFYURLTEMPLATE") 
                 ?? builder.Configuration["Smtp:VerifyUrlTemplate"] ?? "http://auth-service:8080/api/auth/verify";
var redirectUrl = Environment.GetEnvironmentVariable("SMTP__REDIRECTURL") 
                  ?? builder.Configuration["Smtp:RedirectUrl"] ?? "http://localhost:8080/api/auth/verify";
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

builder.Services.Configure<RabbitMqConfig>(builder.Configuration.GetSection("RabbitMq"));
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
    RabbitMqConfig prodRabbitEnvironment;
    try
    {
        prodRabbitEnvironment = new RabbitMqConfig
        {
            Host = Environment.GetEnvironmentVariable("RABBITMQ__HOST") ??
                                        builder.Configuration["RabbitMq:Host"] ?? "localhost",
            Username = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME") ??
                       builder.Configuration["RabbitMq:Username"] ?? "guest",
            Password = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD") ??
                       builder.Configuration["RabbitMq:Password"] ?? "guest",
            VirtualHost = builder.Configuration["RabbitMq:VirtualHost"] ??
                          Environment.GetEnvironmentVariable("RABBITMQ__VHOST") ?? "/",
            Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var a) ? a :
                bool.TryParse(builder.Configuration["RabbitMq:UseSsl"], out var useSsl) && useSsl ? (ushort)5671 :
                (ushort)5672,
            UseSsl = bool.TryParse(Environment.GetEnvironmentVariable(""), out var proSsl) && proSsl
        };
    }
    catch
    {
        prodRabbitEnvironment =
            builder.Configuration.GetSection("RabbitMq").Get<RabbitMqConfig>()
            ?? throw new Exception("Rabbitmq config is missing") ;

    }
    
    configurator.UsingRabbitMq((context, config) =>
    {
        config.Host(prodRabbitEnvironment.Host, prodRabbitEnvironment.Port ,prodRabbitEnvironment.VirtualHost, h =>
        {
            h.Username(prodRabbitEnvironment.Username);
            h.Password(prodRabbitEnvironment.Password);
            if (prodRabbitEnvironment.UseSsl)
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
