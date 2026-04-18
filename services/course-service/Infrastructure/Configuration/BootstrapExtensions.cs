using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (course-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class CourseBootstrapExtensions
{
    // u2500u2500 Authorization policies (course-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddCourseAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(options =>
        {
            options.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser().Build();
            options.AddPolicy(Roles.User, p => p.RequireRole(Roles.User));
            options.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));

            options.AddPolicy(CourseScope.CourseRead, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(CourseScope.CourseRead) || c.User.IsInRole(Roles.User)));
            options.AddPolicy(CourseScope.CourseEnroll, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(CourseScope.CourseEnroll) || c.User.IsInRole(Roles.User)));
            options.AddPolicy(CourseScope.CourseComplete, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(CourseScope.CourseComplete) || c.User.IsInRole(Roles.User)));
            options.AddPolicy(CourseScope.CourseManage, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(CourseScope.CourseManage) || c.User.IsInRole(Roles.Admin)));
        });
        return services;
    }
}
