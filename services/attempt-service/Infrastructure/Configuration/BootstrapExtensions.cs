using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace Microsoft.Extensions.DependencyInjection;

// ─── Bootstrap extensions (attempt-service specific) ────────────────────────────

public static class AttemptBootstrapExtensions
{
    // ── Authorization policies (attempt-service specific) ─────────────────────

    public static IServiceCollection AddAttemptAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(opts =>
        {
            opts.FallbackPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser().Build();

            opts.AddPolicy(Roles.User, a => a.RequireRole(Roles.User));
            opts.AddPolicy(Roles.Admin, a => a.RequireRole(Roles.Admin));

            opts.AddPolicy(AttemptScope.AttemptStart, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptStart) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptSubmit, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptSubmit) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptReadOwn, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptReadOwn) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(AttemptScope.AttemptReadAny, a => a.RequireAssertion(c =>
                c.User.HasAnyScope(AttemptScope.AttemptReadAny) || c.User.IsInRole(Roles.Admin)));
        });
        return services;
    }

    // ── JSON serialization ─────────────────────────────────────────────────────

    public static IServiceCollection AddLangfensJson(this IServiceCollection services)
    {
        services.ConfigureHttpJsonOptions(opts =>
        {
            opts.SerializerOptions.PropertyNameCaseInsensitive = true;
            opts.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        });
        return services;
    }
}
