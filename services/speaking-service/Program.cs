using System.Text;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using speaking_service.Contracts;
using speaking_service.Features;
using speaking_service.Features.Helper;
using speaking_service.Features.Services.Helper;
using speaking_service.Features.Services.User;
using speaking_service.Features.Services.Admin;
using speaking_service.Infrastructure.Persistence;
using Whisper.net;
using Whisper.net.LibraryLoader;
using MassTransit;
using System.Security.Authentication;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Connectors.Google;
using speaking_service.Features.RabbitMq;
using speaking_service.Features.Storage;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

Env.Load();
var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<RabbitMqConfig>(builder.Configuration.GetSection("RabbitMq"));
builder.Services.AddSingleton<CloudinaryConfig>();
builder.Services.AddSingleton(option =>
{
    var config = option.GetRequiredService<CloudinaryConfig>();
    var account = new Account { ApiSecret = config.ApiSecret, ApiKey = config.ApiKey, Cloud = config.CloudName };
    var cloudinary = new Cloudinary(account) { Api = { Secure = true } };
    return cloudinary;
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{

    option.SwaggerDoc("v1", new OpenApiInfo()
    {
        Title = "Speaking-service"
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

var connectionString = Environment.GetEnvironmentVariable("CONNECTIONSTRING__SPEAKING") ??
                       builder.Configuration.GetConnectionString("Speaking_DB");
builder.Services.AddDbContext<SpeakingDbContext>(option => option.UseNpgsql(connectionString));
builder.Services.AddCors(option =>
{
    option.AddPolicy(
        "FE",
        policy =>
            policy
                .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials()
    );
});

builder.Services.AddMassTransit(configurator =>
{
    configurator.AddConsumer<SpeakingGradingConsumer>();
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
            ?? throw new Exception("Rabbitmq config is missing");

    }
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

        });
        config.ReceiveEndpoint("test-speaking", k => k.ConfigureConsumer<SpeakingGradingConsumer>(bus));
    });



});


builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddSingleton<ICloudinaryService, CloudinaryService>();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(option =>
    {
        option.MapInboundClaims = false;
        option.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JwtSettings:Issuer"]
                          ?? throw new Exception("valid issuer is missing"),
            ValidAudience = builder.Configuration["JwtSettings:Audience"]
                            ?? throw new Exception("valid issuer is missing"),
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:SignKey"]
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

    option.AddPolicy(SpeakingScope.SpeakingCreate, p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingCreate)
             || o.User.IsInRole(Roles.Admin)));
    option.AddPolicy(SpeakingScope.SpeakingStart, p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingStart)
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(SpeakingScope.SpeakingViewOwn, p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingViewOwn)
             || o.User.IsInRole(Roles.User)));
    option.AddPolicy(SpeakingScope.SpeakingViewAny, p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingViewAny)
             || o.User.IsInRole(Roles.Admin)));

    option.AddPolicy("UserScope", p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingStart)
             || o.User.HasAnyScope(SpeakingScope.SpeakingViewOwn) || o.User.IsInRole(Roles.User)));
    option.AddPolicy("AdminScope", p => p.RequireAssertion(
        o => o.User.HasAnyScope(SpeakingScope.SpeakingCreate)
             || o.User.HasAnyScope(SpeakingScope.SpeakingViewAny) || o.User.IsInRole(Roles.Admin)));
});

var geminiApiKey = Environment.GetEnvironmentVariable("GEMINI__APIKEY")
                  ?? builder.Configuration["GEMINI:APIKEY"]
                  ?? throw new Exception("GEMINI__APIKEY is missing");
var geminiModel = Environment.GetEnvironmentVariable("GEMINI__MODEL")
                 ?? builder.Configuration["GEMINI:Model"]
                 ?? "gemini-2.5-flash-lite";
builder.Services.AddKernel().AddGoogleAIGeminiChatCompletion(
    modelId: geminiModel,
    apiKey: geminiApiKey,
    apiVersion: GoogleAIVersion.V1_Beta
);

builder.Services.AddSingleton<WhisperFactory>(_ =>
{
    RuntimeOptions.RuntimeLibraryOrder =
    [
        RuntimeLibrary.Cuda,
        RuntimeLibrary.Cpu,
        RuntimeLibrary.CpuNoAvx
    ];
    var modelPath = WhisperModelHelper.EnsureModelDownloadedAsync().GetAwaiter().GetResult();
    return WhisperFactory.FromPath(modelPath);
});


builder.Services.AddHttpClient<IAudioDownloader, AudioDownloader>();


builder.Services.AddScoped<IWhisperService, WhisperService>();
builder.Services.AddScoped<ISpeakingService, SpeakingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddSingleton<ISpeakingGrader, SpeakingGrader>();
builder.Services.AddSingleton<IAudioDownloader, AudioDownloader>();
builder.Services.AddHttpContextAccessor();
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SpeakingDbContext>();
    await db.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.MapSpeakingEndpoint();
app.MapWebsocketSpeaking();
app.MapSpeakingAdminEndpoint();
app.MapUploadEndpoint();





app.Run();
