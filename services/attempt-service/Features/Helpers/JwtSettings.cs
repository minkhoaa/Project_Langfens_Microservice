namespace attempt_service.Features.Helpers;

public class JwtSettings
{
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public string SignKey { get; set; } = string.Empty;
    public int AccessTokenLifetimeSeconds { get; set; } = 15;
}