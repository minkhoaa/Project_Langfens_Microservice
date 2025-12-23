using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Authentication;
using System.Text;
using DotNetEnv;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.SemanticKernel;
using Shared.ExamDto.Contracts.Writing;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using writing_service.Contracts;
using writing_service.Features;
using writing_service.Features.Helper;
using writing_service.Features.RabbitMq;
using writing_service.Features.Service.Admin;
using writing_service.Features.Service.User;
using writing_service.Infrastructure.Persistence;

Env.Load();
var builder = WebApplication.CreateBuilder(args);
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

static string EnvOrDefault(string key, string fallback) => Environment.GetEnvironmentVariable(key) ?? fallback;

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo()
    {
        Title = "Writing-service"
    });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme()
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
            new OpenApiSecurityScheme()
            {
                Reference = new OpenApiReference()
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
            },
            Array.Empty<string>()
        }
    });
});
    // RabbitMQ config now pulled from environment
builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});
builder.Services.AddHttpContextAccessor();
var writingConnectionString = EnvOrDefault("CONNECTIONSTRING__WRITING",
    "Host=writing-database;Port=5432;Database=writing-db;Username=writing;Password=writing");
if (string.IsNullOrWhiteSpace(writingConnectionString))
    throw new Exception("Connection string for writing DB is missing");

// Enable dynamic JSON for JSONB columns (required for List<string> mapping)
var dataSourceBuilder = new Npgsql.NpgsqlDataSourceBuilder(writingConnectionString);
dataSourceBuilder.EnableDynamicJson();
var dataSource = dataSourceBuilder.Build();

builder.Services.AddDbContext<WritingDbContext>(option => option.UseNpgsql(dataSource));
builder.Services.AddScoped<IWritingService, WritingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IUserContext, UserContext>();

builder.Services.AddSingleton<IWritingGrader, WritingGrader>();
var jwtSettings = new
{
    Issuer = EnvOrDefault("JwtSettings__Issuer", "IssuerName"),
    Audience = EnvOrDefault("JwtSettings__Audience", "AudienceName"),
    SignKey = EnvOrDefault("JwtSettings__SignKey", "bTNGPmniBGyINHPdsmONct16TIqqb1bZ")
};

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
        option.MapInboundClaims = false;
        option.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtSettings.Issuer
                          ?? throw new Exception("valid issuer is missing"),
            ValidAudience = jwtSettings.Audience
                            ?? throw new Exception("valid issuer is missing"),
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SignKey
                                                                               ?? throw new Exception("Signing key is missing"))),
            ClockSkew = TimeSpan.Zero,
            NameClaimType = CustomClaims.Sub,
            RoleClaimType = CustomClaims.Roles
        };
    });

builder.Services.AddAuthorization(option =>
{
    option.AddPolicy(Roles.User, o => o.RequireRole(Roles.User));
    option.AddPolicy(Roles.Admin, o => o.RequireRole(Roles.Admin));

    option.AddPolicy(WritingScope.WritingCreate, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingCreate)
             || o.User.IsInRole(Roles.Admin)));
    option.AddPolicy(WritingScope.WritingStart, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingStart)
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(WritingScope.WritingViewOwn, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingViewOwn)
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(WritingScope.WritingViewAny, p => p.RequireAssertion(
        o => o.User.HasAnyScope(WritingScope.WritingViewAny)
             || o.User.IsInRole(Roles.Admin)));
});
builder.Services.AddMassTransit(configurator =>
    {

        configurator.AddConsumer<WritingSubmittedConsumer>();
        var prodRabbitEnvironment = new RabbitMqConfig
        {
            Host = EnvOrDefault("RABBITMQ__HOST", "localhost"),
            Username = EnvOrDefault("RABBITMQ__USERNAME", "guest"),
            Password = EnvOrDefault("RABBITMQ__PASSWORD", "guest"),
            VirtualHost = EnvOrDefault("RABBITMQ__VHOST", "/"),
            Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var a) ? a : (ushort)5672,
            UseSsl = bool.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__USESSL"), out var proSsl) && proSsl
        };
    configurator.UsingRabbitMq((bus, config) =>
    {
        config.Host(prodRabbitEnvironment.Host, prodRabbitEnvironment.Port, prodRabbitEnvironment.VirtualHost,
        h =>
        {
            h.Username(prodRabbitEnvironment.Username);
            h.Password(prodRabbitEnvironment.Password);
            if (prodRabbitEnvironment.UseSsl)
            {
                h.UseSsl(k => k.Protocol = SslProtocols.Tls12);
            }

        }
        );
        config.ReceiveEndpoint("test-writing", k => k.ConfigureConsumer<WritingSubmittedConsumer>(bus));
    });



    });
    var geminiApiKey = Environment.GetEnvironmentVariable("GEMINI__APIKEY")
                      ?? throw new Exception("GEMINI__APIKEY invalid");
    var geminiModel = Environment.GetEnvironmentVariable("GEMINI__MODEL")
                     ?? "gemini-2.5-flash-lite";
builder.Services.AddKernel().AddGoogleAIGeminiChatCompletion(
    modelId: geminiModel,
    apiKey: geminiApiKey,
    apiVersion: Microsoft.SemanticKernel.Connectors.Google.GoogleAIVersion.V1_Beta
);



var app = builder.Build();

// Configure the HTTP request pipeline.

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<WritingDbContext>();
    await db.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();



app.MapWritingEndpoint();
app.MapWritingAdminEndpoint();
app.Run();
