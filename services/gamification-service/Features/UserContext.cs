using System.Security.Claims;
using Shared.Security.Claims;

namespace gamification_service.Features;

public interface IUserContext
{
    Guid UserId { get; }
}

public class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _accessor;

    public UserContext(IHttpContextAccessor accessor)
    {
        _accessor = accessor;
    }

    public Guid UserId
    {
        get
        {
            var sub = _accessor.HttpContext?.User.FindFirstValue(CustomClaims.Sub);
            return Guid.TryParse(sub, out var id) ? id : Guid.Empty;
        }
    }
}
