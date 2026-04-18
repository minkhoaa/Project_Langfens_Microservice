using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace writing_service.Infrastructure.Configuration;

public static class WritingBootstrapExtensions
{
    public static IServiceCollection AddWritingAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(opts =>
        {
            opts.AddPolicy(Roles.User,  o => o.RequireRole(Roles.User));
            opts.AddPolicy(Roles.Admin, o => o.RequireRole(Roles.Admin));
            opts.AddPolicy(WritingScope.WritingCreate, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(WritingScope.WritingCreate) || c.User.IsInRole(Roles.Admin)));
            opts.AddPolicy(WritingScope.WritingStart, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(WritingScope.WritingStart) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(WritingScope.WritingViewOwn, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(WritingScope.WritingViewOwn) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(WritingScope.WritingViewAny, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(WritingScope.WritingViewAny) || c.User.IsInRole(Roles.Admin)));
        });
        return services;
    }
}
