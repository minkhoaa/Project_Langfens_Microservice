using System.IdentityModel.Tokens.Jwt;
using System.Security.Authentication;
using System.Text;
using gamification_service.Features;
using gamification_service.Features.Consumers;
using gamification_service.Infrastructure.Persistence;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;

var builder = WebApplication.CreateBuilder(args);

static string EnvOrDefault(string key, string fallback) => Environment.GetEnvironmentVariable(key) ?? fallback;

var jwtSettings = new
{
    Issuer = EnvOrDefault("JwtSettings__Issuer", "IssuerName"),
    Audience = EnvOrDefault("JwtSettings__Audience", "AudienceName"),
    SignKey = EnvOrDefault("JwtSettings__SignKey", "bTNGPmniBGyINHPdsmONct16TIqqb1bZ")
};

builder.Services.AddCors(option =>
{
    option.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
        option.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SignKey)),
            ClockSkew = TimeSpan.Zero,
            NameClaimType = CustomClaims.Sub,
            RoleClaimType = CustomClaims.Roles
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser().Build();
    options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
    options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Gamification Service", Version = "1.0" });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Description = "Enter token"
    });
    option.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddDbContext<GamificationDbContext>(option => option
    .UseNpgsql(EnvOrDefault("CONNECTIONSTRING__GAMIFICATION", 
        "Host=gamification-database;Port=5432;Database=gamification-db;Username=gamification;Password=gamification"))
);

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddScoped<IGamificationService, GamificationService>();
builder.Services.AddScoped<INotificationService, NotificationService>();

// RabbitMQ consumers
builder.Services.AddMassTransit(configurator =>
{
    configurator.AddConsumer<AttemptCompletedConsumer>();
    configurator.AddConsumer<CardReviewedConsumer>();
    configurator.AddConsumer<LessonCompletedConsumer>();

    var rabbitConfig = new
    {
        Host = EnvOrDefault("RABBITMQ__HOST", "localhost"),
        Username = EnvOrDefault("RABBITMQ__USERNAME", "guest"),
        Password = EnvOrDefault("RABBITMQ__PASSWORD", "guest"),
        VirtualHost = EnvOrDefault("RABBITMQ__VHOST", "/"),
        Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var p) ? p : (ushort)5672,
        UseSsl = bool.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__USESSL"), out var ssl) && ssl
    };

    configurator.UsingRabbitMq((bus, config) =>
    {
        config.Host(rabbitConfig.Host, rabbitConfig.Port, rabbitConfig.VirtualHost, h =>
        {
            h.Username(rabbitConfig.Username);
            h.Password(rabbitConfig.Password);
            if (rabbitConfig.UseSsl)
            {
                h.UseSsl(k => k.Protocol = SslProtocols.Tls12);
            }
        });

        config.ReceiveEndpoint("gamification-attempt-completed", e => e.ConfigureConsumer<AttemptCompletedConsumer>(bus));
        config.ReceiveEndpoint("gamification-card-reviewed", e => e.ConfigureConsumer<CardReviewedConsumer>(bus));
        config.ReceiveEndpoint("gamification-lesson-completed", e => e.ConfigureConsumer<LessonCompletedConsumer>(bus));
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<GamificationDbContext>();
    if (db.Database.IsRelational())
    {
        await db.Database.MigrateAsync();
    }
}

app.MapGamificationEndpoints();
app.MapNotificationEndpoints();
app.Run();

public partial class Program { }
