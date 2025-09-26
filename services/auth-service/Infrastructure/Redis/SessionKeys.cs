namespace auth_service.Infrastructure.Redis;

public static class SessionKeys
{
    public static string Session(string sid) => $"session:{sid}";
    public static string UserDevice(string userId, string deviceId) => $"user:{userId}:device:{deviceId}:sid";
    public static string UserSessions(string userId) => $"user:{userId}:sessions";
}