using System.Security.Claims;
using Shared.Security.Claims;

namespace writing_service.Features.Helper;

public static class UserHelper
{
    public static Guid GetUserId(ClaimsPrincipal claimsPrincipal)
    {
        return Guid.Parse(claimsPrincipal.FindFirstValue(CustomClaims.Sub)!);
    }
    
}