using System.Security.Authentication;
using email_service.Contracts;
using email_service.Features;
using email_service.Features.Service;
using MassTransit;
using Shared.ExamDto.Contracts.Auth_Email;

var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<RabbitMqConfig>(builder.Configuration.GetSection("RabbitMq"));


builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection("Smtp"));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IEmailSender, EmailSender>();
builder.Services.AddMassTransit(configurator =>
{
    // Use unique endpoint names per service so fan-out works (no competing consumers)
    configurator.SetKebabCaseEndpointNameFormatter();
    configurator.AddConsumer<TestpingConsumer>();

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
        config.ReceiveEndpoint("email-service", e => e.ConfigureConsumer<TestpingConsumer>(context));
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
app.Run();
