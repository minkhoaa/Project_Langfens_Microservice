using System.Net.Http.Headers;
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

Env.Load();
var builder = WebApplication.CreateBuilder(args);

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

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IUserContext, UserContext>();
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
builder.Services.Configure<OpenRouterOptions>(builder.Configuration.GetSection("OpenRouter"));
var openRouterSettings = builder.Configuration.GetSection("OpenRouter").Get<OpenRouterOptions>() ?? new OpenRouterOptions();

// Prefer env values when non-empty; fall back to appsettings
var envApiKey = Environment.GetEnvironmentVariable("LLM__APIKEY");
var apiKey = string.IsNullOrWhiteSpace(envApiKey) ? openRouterSettings.ApiKey : envApiKey;

var envBaseUrl = Environment.GetEnvironmentVariable("OPENROUTER__BASEURL");
var baseUrl = string.IsNullOrWhiteSpace(envBaseUrl) ? openRouterSettings.BaseUrl : envBaseUrl;
if (string.IsNullOrWhiteSpace(baseUrl))
    throw new Exception("OpenRouter base url is missing");
baseUrl = baseUrl.TrimEnd('/') + "/";

var envModel = Environment.GetEnvironmentVariable("OPENROUTER__MODEL");
var model = string.IsNullOrWhiteSpace(envModel) ? openRouterSettings.Model : envModel;

if (string.IsNullOrWhiteSpace(apiKey))
    throw new Exception("LLM api key is missing");
builder.Services.AddHttpClient("openrouter", client =>
{
    client.BaseAddress = new Uri(baseUrl);
    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
    if (!string.IsNullOrWhiteSpace(openRouterSettings.Referer))
        client.DefaultRequestHeaders.Add("HTTP-Referer", openRouterSettings.Referer);

    if (!string.IsNullOrWhiteSpace(openRouterSettings.Title))
        client.DefaultRequestHeaders.Add("X-Title", openRouterSettings.Title);
});

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
builder.Services.AddScoped<IWhisperService, WhisperService>();
builder.Services.AddScoped<ISpeakingService, SpeakingService>();
builder.Services.AddScoped<IAdminService, AdminService>();
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

app.UseWebSockets();
app.Run();
