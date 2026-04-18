using System.Security.Authentication;
using System.Text;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Shared.Bootstrap;
using Shared.Security.Claims;

namespace Microsoft.Extensions.DependencyInjection;

public static class LangfensBootstrapExtensions
{
    public static IServiceCollection AddLangfensAuth(
        this IServiceCollection services,
        Func<string, string?> getEnv,
        bool saveToken = true,
        bool mapInboundClaims = false)
    {
        var issuer  = getEnv("JwtSettings__Issuer")
                      ?? throw new InvalidOperationException("JwtSettings__Issuer is required");
        var aud     = getEnv("JwtSettings__Audience")
                      ?? throw new InvalidOperationException("JwtSettings__Audience is required");
        var signKey = getEnv("JwtSettings__SignKey")
                      ?? throw new InvalidOperationException("JwtSettings__SignKey is required");

        var jwt = new JwtSettings
        {
            Issuer = issuer,
            Audience = aud,
            SignKey = signKey,
            AccessTokenLifetimeSeconds = int.TryParse(
                getEnv("JwtSettings__AccessTokenLifetimeSeconds"), out var ttl) ? ttl : 15,
        };
        services.AddSingleton(jwt);

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.SaveToken = saveToken;
                options.MapInboundClaims = mapInboundClaims;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateIssuerSigningKey = true,
                    ValidateLifetime = true,
                    ValidIssuer = jwt.Issuer,
                    ValidAudience = jwt.Audience,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SignKey)),
                    ClockSkew = TimeSpan.Zero,
                    NameClaimType = CustomClaims.Sub,
                    RoleClaimType = CustomClaims.Roles,
                };
            });

        return services;
    }

    public static IServiceCollection AddLangfensCors(
        this IServiceCollection services,
        string[]? defaultOrigins = null)
    {
        var defaults = defaultOrigins != null
            ? string.Join(",", defaultOrigins)
            : "http://localhost:3000,http://127.0.0.1:3000";
        var origins = (Environment.GetEnvironmentVariable("CORS_ALLOWED_ORIGINS") ?? defaults)
            .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        services.AddCors(options =>
        {
            options.AddPolicy("FE", policy => policy
                .WithOrigins(origins)
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials());
        });
        return services;
    }

    public static IServiceCollection AddLangfensSwagger(
        this IServiceCollection services,
        string title)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc("v1", new OpenApiInfo { Title = title, Version = "v1" });
            options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.Http,
                Scheme = "Bearer",
                BearerFormat = "JWT",
                Description = "Enter token",
            });
            options.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
                    },
                    Array.Empty<string>()
                },
            });
        });
        return services;
    }

    public static RabbitMqConfig BuildRabbitMqConfig(Func<string, string?> getEnv)
    {
        return new RabbitMqConfig
        {
            Host        = getEnv("RABBITMQ__HOST") ?? "localhost",
            Username    = getEnv("RABBITMQ__USERNAME")
                          ?? throw new InvalidOperationException("RABBITMQ__USERNAME is required"),
            Password    = getEnv("RABBITMQ__PASSWORD")
                          ?? throw new InvalidOperationException("RABBITMQ__PASSWORD is required"),
            VirtualHost = getEnv("RABBITMQ__VHOST") ?? "/",
            Port        = ushort.TryParse(getEnv("RABBITMQ__PORT"), out var p) ? p : (ushort)5672,
            UseSsl      = bool.TryParse(getEnv("RABBITMQ__USESSL"), out var s) && s,
        };
    }

    public static void ConfigureRabbitMqHost(
        this IRabbitMqBusFactoryConfigurator configurator,
        RabbitMqConfig config)
    {
        configurator.Host(config.Host, config.Port, config.VirtualHost, h =>
        {
            h.Username(config.Username);
            h.Password(config.Password);
            if (config.UseSsl)
                h.UseSsl(k => k.Protocol = SslProtocols.Tls12);
        });
    }
}
