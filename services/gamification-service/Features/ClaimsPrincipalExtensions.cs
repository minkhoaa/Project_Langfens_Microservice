using System.Security.Claims;

namespace gamification_service.Features;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal principal)
    {
        var sub = principal.FindFirstValue("sub");
        if (string.IsNullOrEmpty(sub) || !Guid.TryParse(sub, out var userId))
            throw new UnauthorizedAccessException("Invalid or missing user ID");
        return userId;
    }
}
