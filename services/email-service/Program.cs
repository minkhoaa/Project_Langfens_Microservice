using EmailService;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Email Service",
        Version = "v1",
        Description = "Minimal API for sending templated emails"
    });
});

builder.Services.AddSingleton(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    return EmailSettings.FromConfiguration(configuration);
});

builder.Services.AddSingleton<EmailTemplateRenderer>();
builder.Services.AddSingleton<SmtpEmailSender>();
builder.Services.AddSingleton<TemplatedEmailService>();
builder.Services.AddHostedService<RabbitMqMailConsumer>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapPost("/api/email/send", async Task<IResult> (SendEmailRequest request, TemplatedEmailService mailService, CancellationToken cancellationToken) =>
{
    if (!request.TryValidate(out var errors))
    {
        return Results.ValidationProblem(errors);
    }

    var command = request.ToEmailCommand();
    await mailService.SendAsync(command, cancellationToken);

    return Results.Ok(new { ok = true });
})
.WithName("SendEmail")
.WithOpenApi();

app.MapGet("/health", () => Results.Ok(new { status = "ok" }))
   .WithName("HealthCheck");

app.Run();
