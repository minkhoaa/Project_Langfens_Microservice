using email_service.Contracts;
using email_service.Features.Service;
using Microsoft.AspNetCore.Identity;

var builder = WebApplication.CreateBuilder(args);


builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection("Smtp"));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IEmailSender, EmailSender>();
var app = builder.Build();



app.UseSwagger();
app.UseSwaggerUI();
app.MapPost("/send-otp", async (string email, string otp, IEmailSender mailer, CancellationToken token = default) =>
{
    await mailer.SendOtpAsync(email, otp, ttlSeconds: 300, token);
    return Results.Ok(new { success = true });
});

app.Run();

