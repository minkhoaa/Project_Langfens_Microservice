using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Shared.Security.Helper;
using Shared.Security.Roles;
using Shared.Security.Scopes;

namespace Microsoft.Extensions.DependencyInjection;

// u2500u2500u2500 Bootstrap extensions (exam-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

public static class ExamBootstrapExtensions
{
    // u2500u2500 Authorization policies (exam-service specific) u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static IServiceCollection AddExamAuthorization(this IServiceCollection services)
    {
        services.AddAuthorization(opts =>
        {
            // No FallbackPolicy: endpoints opt in to auth via .RequireAuthorization(...) or
            // [Authorize] on the endpoint, which lets ServiceDefaults' /health and /alive
            // (mapped with .AllowAnonymous()) bypass the JwtBearer challenge cleanly.

            opts.AddPolicy(Roles.User,  p => p.RequireRole(Roles.User));
            opts.AddPolicy(Roles.Admin, p => p.RequireRole(Roles.Admin));

            opts.AddPolicy(ExamScope.ExamRead, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(ExamScope.ExamRead) || c.User.IsInRole(Roles.User)));
            opts.AddPolicy(ExamScope.ExamManage, p => p.RequireAssertion(c =>
                c.User.HasAnyScope(ExamScope.ExamManage) || c.User.IsInRole(Roles.Admin)));

            // AdminPolicy is the canonical alias for admin-only write endpoints
            // (e.g. POST /api/admin/questions). Accepts either the Admin role or the
            // exam.manage scope so the same policy works for human admins and service-to-service
            // callers.
            opts.AddPolicy("AdminPolicy", p => p.RequireAssertion(c =>
                c.User.IsInRole(Roles.Admin) || c.User.HasAnyScope(ExamScope.ExamManage)));
        });
        return services;
    }

    // u2500u2500 Kestrel HTTP + gRPC ports u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500u2500

    public static void ConfigureLangfensKestrel(this WebApplicationBuilder builder, int httpPort = 8080, int grpcPort = 8081)
    {
        builder.WebHost.ConfigureKestrel(o =>
        {
            o.ListenAnyIP(httpPort, lo => lo.Protocols = HttpProtocols.Http1);
            o.ListenAnyIP(grpcPort, lo => lo.Protocols = HttpProtocols.Http2);
        });
    }
}
