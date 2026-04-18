using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Shared.Bootstrap;
using Shared.Security.Claims;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (auth-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class AuthBootstrapExtensions
{
    // u2500u2500u2500 Env-driven auth (non-auth services pattern) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddLangfensAuthEnv(
        this IServiceCollection services,
        Func<string, string?> getEnv)
    {
        var issuer  = getEnv("JwtSettings__Issuer")
                      ?? throw new InvalidOperationException("JwtSettings__Issuer is required");
        var aud     = getEnv("JwtSettings__Audience")
                      ?? throw new InvalidOperationException("JwtSettings__Audience is required");
        var signKey = getEnv("JwtSettings__SignKey")
                      ?? throw new InvalidOperationException("JwtSettings__SignKey is required");

        if (string.IsNullOrWhiteSpace(signKey))
            throw new InvalidOperationException("JwtSettings:SignKey is not configured.");

        var jwt = new JwtSettings
        {
            Issuer = issuer,
            Audience = aud,
            SignKey = signKey,
        };
        services.AddSingleton(jwt);

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.MapInboundClaims = false;
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

        JwtSecurityTokenHandler.DefaultMapInboundClaims = false;
        return services;
    }
}
