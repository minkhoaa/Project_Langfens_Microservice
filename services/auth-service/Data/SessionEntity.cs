using auth_service.Infrastructure.Persistence;

namespace auth_service.Data;

public class SessionEntity
{
    public string UserId { get; set; } = default!;
    public string DeviceId { get; set; } = default!;
    public string Jti { get; set; } = default!;
    public DateTime Exp { get; set; }
    public DateTime LastSeen { get; set; } = DateTime.UtcNow;
    public string? Ua { get; set; }
    public string? Ip { get; set; }
    public string? PrevJti { get; set; } // optional: chống replay chuỗi cũ
    public DateTime? RevokedAt { get; set; }

    public User? user { get; set; }
}