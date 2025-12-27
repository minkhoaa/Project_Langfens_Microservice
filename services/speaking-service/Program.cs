using System.Text;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
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

Env.Load();
var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = 50 * 1024 * 1024; // 50 MB
});

static string EnvOrDefault(string key, string fallback) => Environment.GetEnvironmentVariable(key) ?? fallback;
var jwtSettings = new
{
    Issuer = EnvOrDefault("JwtSettings__Issuer", "IssuerName"),
    Audience = EnvOrDefault("JwtSettings__Audience", "AudienceName"),
    SignKey = EnvOrDefault("JwtSettings__SignKey", "bTNGPmniBGyINHPdsmONct16TIqqb1bZ")
};
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

var connectionString = EnvOrDefault("CONNECTIONSTRING__SPEAKING",
    "Host=speaking-database;Port=5432;Database=speaking-db;Username=speaking;Password=speaking");
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

var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT")
                  ?? throw new Exception("AZURE_OPENAI__ENDPOINT is required");
var azureApiKey = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY")
                  ?? throw new Exception("AZURE_OPENAI__APIKEY is required");
var azureDeployment = EnvOrDefault("AZURE_OPENAI__DEPLOYMENT", "gpt-4o-mini");
builder.Services.AddKernel().AddAzureOpenAIChatCompletion(
    deploymentName: azureDeployment,
    endpoint: azureEndpoint,
    apiKey: azureApiKey
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
