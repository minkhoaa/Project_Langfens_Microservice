using System.Security.Authentication;
using System.Text;
using auth_service.Application.Auth;
using auth_service.Application.Common;
using auth_service.Contracts;
using auth_service.Features.Auth;
using auth_service.Features.RabbitMq;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Security.Claims;
using Shared.Security.Roles;
using StackExchange.Redis;
using Role = auth_service.Infrastructure.Persistence.Role;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>() ?? new JwtSettings();
builder.Services.Configure<RabbitMqConfig>(builder.Configuration.GetSection("RabbitMq")); 

if (string.IsNullOrWhiteSpace(jwtSettings.SignKey))
{
    throw new InvalidOperationException("JwtSettings:SignKey is not configured.");
}

builder.Services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(
    Environment.GetEnvironmentVariable("CONNECTIONSTRING__REDIS")
    ?? builder.Configuration.GetConnectionString("Redis") 
    ?? "localhost:6379"));
builder.Services.AddSingleton(sp => sp.GetRequiredService<IConnectionMultiplexer>().GetDatabase());
builder.Services.AddMassTransit(configurator =>
{
    // Use unique endpoint names per service so fan-out works (no competing consumers)
    configurator.SetEndpointNameFormatter(new KebabCaseEndpointNameFormatter("user-registered", includeNamespace:false));
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
        config.ConfigureEndpoints(context);
    });
});
builder.Services.AddDbContextPool<AuthDbContext>(options =>
{
    options.UseNpgsql(Environment.GetEnvironmentVariable("CONNECTIONSTRING__AUTH")
                      ?? builder.Configuration.GetConnectionString("Default")
                      ?? "Host=auth-database;Port=5432;Database=auth-db;Username=auth;Password=auth");
});
builder.Services.AddIdentityCore<User>(option =>
    {
        option.User.RequireUniqueEmail = true;
        option.Password.RequireDigit = true;
        option.Password.RequireUppercase = true;
        option.Password.RequireLowercase = true;
    })
    .AddRoles<Role>()
    .AddEntityFrameworkStores<AuthDbContext>()
    .AddSignInManager<SignInManager<User>>()
    .AddDefaultTokenProviders();




builder.Services.AddCors(options =>
{
    options.AddPolicy("FE", policy => policy
        .WithOrigins("http://localhost:3000", "http://127.0.0.1:3000")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidAudience = jwtSettings.Audience,
            ValidIssuer = jwtSettings.Issuer,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SignKey)),
            ClockSkew = TimeSpan.Zero,
            NameClaimType = CustomClaims.Sub,
            RoleClaimType = CustomClaims.Roles
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
    options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
});
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Auth Service", Version = "1.0" });
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



// DI
builder.Services.AddScoped<ISessionRepository, SessionRepository>();
builder.Services.AddScoped<ISessionStore, SessionStore>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IOtpGenerator, OtpGenerator>();
builder.Services.AddScoped<IOtpStore, RedisOtpStore>();
builder.Services.AddScoped<IPasswordHasher<string>, PasswordHasher<string>>();
builder.Services.AddSingleton<IEmailValidator, EmailValidator>();
builder.Services.AddSingleton<ICookieService, CookieService>();
builder.Services.AddSingleton<IJwtTokenFactory, JwtTokenFactory>();
builder.Services.AddSingleton<IGoogleTokenVerifier, GoogleTokenVerifier>();


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
    await db.Database.MigrateAsync();
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("FE");

app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();

app.Run();
