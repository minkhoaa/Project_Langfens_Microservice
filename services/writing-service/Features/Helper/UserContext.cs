using System.Security.Claims;
using Shared.Security.Claims;

namespace writing_service.Features.Helper;

public interface IUserContext
{
    ClaimsPrincipal User { get; }
    Guid UserId { get; }
}
public class UserContext : IUserContext
{
    public ClaimsPrincipal User { get; }
    public Guid UserId { get; }

    public UserContext(IHttpContextAccessor context)
    {
        User = context.HttpContext!.User ?? new ClaimsPrincipal(new ClaimsIdentity());
        var idValue =
            User.FindFirstValue(CustomClaims.Sub)
            ?? User.FindFirst(CustomClaims.Sub)?.Value
            ?? User.FindFirst("uid")?.Value;

        if (!string.IsNullOrWhiteSpace(idValue) &&
            Guid.TryParse(idValue, out var guid))
        {
            UserId = guid;
        }
        
    }
}