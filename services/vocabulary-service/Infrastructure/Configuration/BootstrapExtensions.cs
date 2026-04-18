using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (vocabulary-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class VocabularyBootstrapExtensions
{
    // u2500u2500 Authorization policies (vocabulary-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddVocabularyAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(options =>
        {
            options.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser().Build();
            options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
            options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));

            options.AddPolicy(VocabScope.VocabRead, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(VocabScope.VocabRead) || c.User.IsInRole(Roles.User)));
            options.AddPolicy(VocabScope.VocabManage, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(VocabScope.VocabManage) || c.User.IsInRole(Roles.Admin)));
        });
        return services;
    }
}
