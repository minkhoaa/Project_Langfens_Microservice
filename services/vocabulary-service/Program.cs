using System.IdentityModel.Tokens.Jwt;
using System.Text;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.SemanticKernel;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using vocabulary_service.Application;
using vocabulary_service.Features;
using vocabulary_service.Features.Admin;
using vocabulary_service.Features.Public;
using vocabulary_service.Features.User;
using vocabulary_service.Infrastructure.Persistence;

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
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser().Build();
    options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
    options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));

    options.AddPolicy(VocabScope.VocabRead, p => p.RequireAssertion(c =>
        c.User.HasAnyScope(VocabScope.VocabRead) || c.User.IsInRole(Roles.User)));
    options.AddPolicy(VocabScope.VocabManage, p => p.RequireAssertion(c =>
        c.User.HasAnyScope(VocabScope.VocabManage) || c.User.IsInRole(Roles.Admin)));

});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Vocabulary Service", Version = "1.0" });
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
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
    });
builder.Services.AddDbContext<VocabularyDbContext>(option => option.UseNpgsql(
    EnvOrDefault("CONNECTIONSTRING__VOCABULARY", "Host=vocabulary-database;Port=5432;Database=vocabulary-db;Username=vocabulary;Password=vocabulary")
));

builder.Services.AddMassTransit(x =>
{
    var rabbitConfig = new
    {
        Host = EnvOrDefault("RABBITMQ__HOST", "localhost"),
        Username = EnvOrDefault("RABBITMQ__USERNAME", "guest"),
        Password = EnvOrDefault("RABBITMQ__PASSWORD", "guest"),
        VirtualHost = EnvOrDefault("RABBITMQ__VHOST", "/"),
        Port = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var p) ? p : (ushort)5672
    };
    x.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.Host(rabbitConfig.Host, rabbitConfig.Port, rabbitConfig.VirtualHost, h =>
        {
            h.Username(rabbitConfig.Username);
            h.Password(rabbitConfig.Password);
        });
    });
});

// Azure OpenAI for vocabulary enrichment
var azureEndpoint = Environment.GetEnvironmentVariable("AZURE_OPENAI__ENDPOINT");
var azureApiKey = Environment.GetEnvironmentVariable("AZURE_OPENAI__APIKEY");
var azureDeployment = EnvOrDefault("AZURE_OPENAI__DEPLOYMENT", "gpt-4o-mini");
if (!string.IsNullOrWhiteSpace(azureEndpoint) && !string.IsNullOrWhiteSpace(azureApiKey))
{
    builder.Services.AddSingleton(_ => new OpenAI.Chat.ChatClient(
        model: azureDeployment,
        credential: new System.ClientModel.ApiKeyCredential(azureApiKey),
        options: new OpenAI.OpenAIClientOptions { Endpoint = new Uri(azureEndpoint) }
    ));
    Console.WriteLine($"[INFO] Azure OpenAI enabled for vocabulary enrichment with deployment: {azureDeployment}");
}
else
{
    builder.Services.AddSingleton<OpenAI.Chat.ChatClient>(sp => null!);
    Console.WriteLine("[WARN] Azure OpenAI not configured – AI enrichment disabled");
}

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPublicService, PublicService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IAiEnrichmentService, AiEnrichmentService>();
builder.Services.AddScoped<IVocabularyExtractionService, VocabularyExtractionService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.UseAuthentication();
app.UseAuthorization();
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
    if (db.Database.IsRelational())
    {
        await db.Database.MigrateAsync();
    }
}

app.MapPublicVocabularyEndpoints();
app.MapUserVocabularyEndpoints();
app.Run();

public partial class Program { }
