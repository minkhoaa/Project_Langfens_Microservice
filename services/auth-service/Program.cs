using System.Security.Authentication;
using System.Text;
using Aspire.Npgsql.EntityFrameworkCore.PostgreSQL;
using auth_service.Application.Auth;
using auth_service.Application.Common;
using auth_service.Contracts;
using auth_service.Features.Auth;
using auth_service.Features.RabbitMq;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using DotNetEnv;
using HealthChecks.RabbitMQ;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shared.Security.Claims;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;
using StackExchange.Redis;
using Role = auth_service.Infrastructure.Persistence.Role;

Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// ── Shared bootstrap (local extensions, consistent across all services) ───────
builder.Services.AddLangfensAuthEnv(key => Environment.GetEnvironmentVariable(key));
builder.Services.AddLangfensCors();
builder.Services.AddLangfensSwagger("Auth Service");

// ── JWT singleton (auth-service issues tokens, needs full settings) ─────────────
var jwtSettings = new auth_service.Application.Common.JwtSettings
{
    Issuer       = Environment.GetEnvironmentVariable("JwtSettings__Issuer")
                    ?? throw new InvalidOperationException("JwtSettings__Issuer is required"),
    Audience     = Environment.GetEnvironmentVariable("JwtSettings__Audience")
                    ?? throw new InvalidOperationException("JwtSettings__Audience is required"),
    SignKey      = Environment.GetEnvironmentVariable("JwtSettings__SignKey")
                    ?? throw new InvalidOperationException("JwtSettings__SignKey is required"),
    RsaPrivateKeyPem = Environment.GetEnvironmentVariable("JwtSettings__RsaPrivateKeyPem")
                    ?? throw new InvalidOperationException("JwtSettings__RsaPrivateKeyPem is required"),
    KeyId        = Environment.GetEnvironmentVariable("JwtSettings__KeyId")
                    ?? throw new InvalidOperationException("JwtSettings__KeyId is required"),
    AccessTokenLifetimeSeconds = int.TryParse(
        Environment.GetEnvironmentVariable("JwtSettings__AccessTokenLifetimeSeconds"), out var ttl)
            ? ttl : 3600,
};
builder.Services.AddSingleton(jwtSettings);
builder.Services.Configure<auth_service.Application.Common.JwtSettings>(options =>
{
    options.Issuer = jwtSettings.Issuer;
    options.Audience = jwtSettings.Audience;
    options.SignKey = jwtSettings.SignKey;
    options.RsaPrivateKeyPem = jwtSettings.RsaPrivateKeyPem;
    options.KeyId = jwtSettings.KeyId;
    options.AccessTokenLifetimeSeconds = jwtSettings.AccessTokenLifetimeSeconds;
});

// ── RabbitMQ ───────────────────────────────────────────────────────────────────
static string EnvOrDefault(string key, string fallback) =>
    Environment.GetEnvironmentVariable(key) ?? fallback;

var rabbitHost = EnvOrDefault("RABBITMQ__HOST", "localhost");
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ__USERNAME")
                    ?? throw new InvalidOperationException("RABBITMQ__USERNAME is required");
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ__PASSWORD")
                    ?? throw new InvalidOperationException("RABBITMQ__PASSWORD is required");
var rabbitVhost = EnvOrDefault("RABBITMQ__VHOST", "/");
var rabbitPort = ushort.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__PORT"), out var port) ? port : (ushort)5672;
var rabbitUseSsl = bool.TryParse(Environment.GetEnvironmentVariable("RABBITMQ__USESSL"), out var ssl) && ssl;

var rabbitConfig = new RabbitMqConfig
{
    Host       = rabbitHost,
    Port       = rabbitPort,
    VirtualHost= rabbitVhost,
    Username   = rabbitUser,
    Password   = rabbitPass,
    UseSsl     = rabbitUseSsl,
};
builder.Services.AddSingleton(rabbitConfig);

// ── Database (Aspire) ──────────────────────────────────────────────────────────
builder.AddNpgsqlDbContext<AuthDbContext>("auth-db", configureDbContextOptions: opts =>
{
    opts.UseNpgsql(npgsqlOpts => npgsqlOpts.ExecutionStrategy(deps => new Microsoft.EntityFrameworkCore.Storage.NonRetryingExecutionStrategy(deps)));
});

// ── Identity ──────────────────────────────────────────────────────────────────
builder.Services.AddIdentityCore<User>(opt =>
    {
        opt.User.RequireUniqueEmail = true;
        opt.Password.RequireDigit = true;
        opt.Password.RequireUppercase = true;
        opt.Password.RequireLowercase = true;
    })
    .AddRoles<Role>()
    .AddEntityFrameworkStores<AuthDbContext>()
    .AddSignInManager<SignInManager<User>>()
    .AddDefaultTokenProviders();

// ── Authorization policies ────────────────────────────────────────────────────
builder.Services.AddAuthorization(opts =>
{
    opts.AddPolicy(Roles.User,  p => p.RequireRole(Roles.User));
    opts.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
    opts.AddPolicy(UserScope.UserReadAny, p => p.RequireAssertion(ctx =>
        ctx.User.HasAnyScope(UserScope.UserReadAny) || ctx.User.IsInRole(Roles.Admin)));
});

// ── Redis (Aspire) ─────────────────────────────────────────────────────────────
// AddRedisClient registers IConnectionMultiplexer as singleton keyed by name
builder.AddRedisClient("auth-redis");

// ── Health checks ──────────────────────────────────────────────────────────────
var authConnectionString = builder.Configuration.GetConnectionString("auth-db")
    ?? throw new InvalidOperationException("auth-db connection string is required");
var redisConnectionString = builder.Configuration.GetConnectionString("auth-redis")
    ?? "localhost:6379";

builder.Services.AddHealthChecks()
    .AddNpgSql(authConnectionString, name: "auth-db", failureStatus: HealthStatus.Unhealthy, tags: new[] { "db", "postgresql" })
    .AddRedis(redisConnectionString, name: "auth-redis", failureStatus: HealthStatus.Unhealthy, tags: new[] { "cache" });

// ── DI ───────────────────────────────────────────────────────────────────────
// IConnectionMultiplexer registered directly by AddRedisClient
builder.Services.AddSingleton(sp => sp.GetRequiredService<IConnectionMultiplexer>().GetDatabase());

builder.Services.AddScoped<ISessionRepository, SessionRepository>();
builder.Services.AddScoped<ISessionStore,      SessionStore>();
builder.Services.AddScoped<IAuthService,       AuthService>();
builder.Services.AddScoped<IOtpGenerator,      OtpGenerator>();
builder.Services.AddScoped<IOtpStore,         RedisOtpStore>();
builder.Services.AddScoped<IPasswordHasher<string>, PasswordHasher<string>>();
builder.Services.AddSingleton<IEmailValidator, EmailValidator>();
builder.Services.AddSingleton<ICookieService,   CookieService>();
builder.Services.AddSingleton<IJwtTokenFactory,JwtTokenFactory>();
builder.Services.AddSingleton<IGoogleTokenVerifier, GoogleTokenVerifier>();

// ── MassTransit (RabbitMQ) ────────────────────────────────────────────────────
builder.Services.AddMassTransit(config =>
{
    config.SetEndpointNameFormatter(new KebabCaseEndpointNameFormatter("user-registered", includeNamespace: false));
    config.UsingRabbitMq((ctx, cfg) =>
    {
        cfg.Host(rabbitHost, rabbitPort, rabbitVhost, h =>
        {
            h.Username(rabbitUser);
            h.Password(rabbitPass);
            if (rabbitUseSsl) h.UseSsl(k => k.Protocol = SslProtocols.Tls12);
        });
        cfg.ConfigureEndpoints(ctx);
    });
});

// ── App ───────────────────────────────────────────────────────────────────────
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
    await db.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("FE");
app.MapDefaultEndpoints();
app.UseAuthentication();
app.UseAuthorization();
app.MapAuthEndpoints();
app.Run();

public partial class Program { }