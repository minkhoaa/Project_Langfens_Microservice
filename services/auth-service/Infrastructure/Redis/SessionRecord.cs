namespace auth_service.Infrastructure.Redis;

public record SessionRecord(
    string Sid,
    string UserId,
    string Jti,
    DateTime Exp,
    string? DeviceId,
    string? Ua,
    string? Ip
);
