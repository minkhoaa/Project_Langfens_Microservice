namespace auth_service.Application.Common;

public interface ICookieService
{
    CookieOptions CreateSessionCookie(DateTimeOffset expiresAt);
    CookieOptions CreateRemovalCookie();
}

public class CookieService : ICookieService
{
    private readonly IConfiguration _configuration;

    public CookieService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public CookieOptions CreateSessionCookie(DateTimeOffset expiresAt)
    {
        var options = new CookieOptions
        {
            HttpOnly = true,
            SameSite = SameSiteMode.Lax,
            Secure = _configuration.GetValue("Cookies:Secure", false),
            Path = "/",
            Expires = expiresAt,
            IsEssential = true
        };

        var domain = _configuration["Cookies:Domain"];
        if (!string.IsNullOrWhiteSpace(domain))
        {
            options.Domain = domain;
        }

        return options;
    }

    public CookieOptions CreateRemovalCookie()
    {
        var options = new CookieOptions
        {
            HttpOnly = true,
            SameSite = SameSiteMode.Lax,
            Secure = _configuration.GetValue("Cookies:Secure", false),
            Path = "/",
            Expires = DateTimeOffset.UnixEpoch,
            IsEssential = true
        };

        var domain = _configuration["Cookies:Domain"];
        if (!string.IsNullOrWhiteSpace(domain))
        {
            options.Domain = domain;
        }

        return options;
    }
}