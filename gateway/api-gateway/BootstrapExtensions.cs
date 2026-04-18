using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Shared.Bootstrap;
using Shared.Security.Claims;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (api-gateway specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class GatewayBootstrapExtensions
{
    // u2500u2500u2500 Config-driven auth (gateway pattern) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddLangfensAuth(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var section = configuration.GetSection("JwtSettings");
        var jwt = section.Get<JwtSettings>();

        if (jwt is null || string.IsNullOrWhiteSpace(jwt.SignKey))
            throw new InvalidOperationException("JwtSettings__SignKey is required");

        services.Configure<JwtSettings>(section);

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
