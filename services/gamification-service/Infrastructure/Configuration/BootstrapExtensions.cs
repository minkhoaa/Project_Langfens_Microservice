using Shared.Security.Roles;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (gamification-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class GamificationBootstrapExtensions
{
    // u2500u2500 Authorization (gamification-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddGamificationAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(opts =>
        {
            opts.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser().Build();
            opts.AddPolicy(Roles.User,  p => p.RequireRole(Roles.User));
            opts.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));
        });
        return services;
    }
}
