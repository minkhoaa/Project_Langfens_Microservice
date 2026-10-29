using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Shared.Security.Roles;

namespace exam_service.Features.Exams.InternalEndpoint;

public sealed class InternalExamAccess(IConfiguration configuration)
    : AuthorizationHandler<InternalExamAccess.Requirement>
{
    public const string Policy = "InternalExamAccess";
    public const string Header = "X-Internal-Key";

    public sealed class Requirement : IAuthorizationRequirement;

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, Requirement requirement)
    {
        if (context.User.Identities.Any(i => i.IsAuthenticated) && context.User.IsInRole(Roles.Admin))
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        // gRPC metadata is exposed as HTTP/2 headers by the same authorization pipeline.
        var expected = configuration["EXAMSERVICE:INTERNAL:API:KEY"];
        if (!string.IsNullOrWhiteSpace(expected) && context.Resource is HttpContext http &&
            http.Request.Headers.TryGetValue(Header, out var supplied) && supplied.Count == 1 &&
            CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(expected),
                Encoding.UTF8.GetBytes(supplied[0] ?? string.Empty)))
            context.Succeed(requirement);

        return Task.CompletedTask;
    }
}
