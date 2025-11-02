
using System.Security.Claims;
using Shared.Security.Claims;

namespace Shared.Security.Helper;

public static class AuthExtension
{
    public static bool HasAnyScope(this ClaimsPrincipal user, params string[] scopes)
    {
        var raw = user.FindFirst(CustomClaims.Scope)?.Value ?? "";
        var set = raw.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        foreach (var s in scopes)
            if (Array.IndexOf(set, s) >= 0)
                return true;
        return false; 
    }
}