namespace auth_service.Application.Common;

public class JwtSettings
{
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public string SignKey { get; set; } = string.Empty;
    public string RsaPrivateKeyPem { get; set; } = null!; // lấy từ secret store
    public string KeyId { get; set; } = "key-2025-11";
    public int AccessTokenLifetimeSeconds { get; set; } = 3600;
}