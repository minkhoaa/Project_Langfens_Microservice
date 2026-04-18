using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (speaking-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class SpeakingBootstrapExtensions
{
    // u2500u2500 Authorization policies (speaking-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddSpeakingAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(option =>
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
        return services;
    }
}
