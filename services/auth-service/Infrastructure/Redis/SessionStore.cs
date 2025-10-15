using System.Text.Json;
using StackExchange.Redis;

namespace auth_service.Infrastructure.Redis;

public interface ISessionStore
{
    Task StoreSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct);
    Task<SessionRecord?> GetSessionAsync(string sid, CancellationToken ct);
    Task RemoveSessionAsync(SessionRecord record, CancellationToken ct);
    Task SetDeviceSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct);
    Task EnsureSessionLimitAsync(string userId, int maxSessions, CancellationToken ct);
    Task RefreshSessionTtlAsync(string sid, TimeSpan ttl, CancellationToken ct);
}

public class SessionStore(IDatabase database) : ISessionStore
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    public Task StoreSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct)
    {
        var value = JsonSerializer.Serialize(record, SerializerOptions);
        return database.StringSetAsync(SessionKeys.Session(record.Sid), value, ttl);
    }

    public async Task<SessionRecord?> GetSessionAsync(string sid, CancellationToken ct)
    {
        var value = await database.StringGetAsync(SessionKeys.Session(sid));
        if (value.IsNullOrEmpty)
        {
            return null;
        }

        return JsonSerializer.Deserialize<SessionRecord>(value!, SerializerOptions);
    }

    public async Task RemoveSessionAsync(SessionRecord record, CancellationToken ct)
    {
        await database.KeyDeleteAsync(SessionKeys.Session(record.Sid));
        await database.SortedSetRemoveAsync(SessionKeys.UserSessions(record.UserId), record.Sid);
        if (!string.IsNullOrWhiteSpace(record.DeviceId))
        {
            await database.KeyDeleteAsync(SessionKeys.UserDevice(record.UserId, record.DeviceId!));
        }
    }

    public async Task SetDeviceSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(record.DeviceId))
        {
            return;
        }

        var deviceKey = SessionKeys.UserDevice(record.UserId, record.DeviceId!);
        var oldSid = await database.StringGetAsync(deviceKey);
        if (!oldSid.IsNullOrEmpty)
        {
            if (!string.Equals(oldSid!, record.Sid, StringComparison.Ordinal))
            {
                await database.KeyDeleteAsync(SessionKeys.Session(oldSid!));
            }

            await database.SortedSetRemoveAsync(SessionKeys.UserSessions(record.UserId), oldSid!);
        }

        await database.StringSetAsync(deviceKey, record.Sid, ttl);
        await database.SortedSetAddAsync(SessionKeys.UserSessions(record.UserId), record.Sid,
            DateTimeOffset.UtcNow.ToUnixTimeSeconds());
    }

    public async Task EnsureSessionLimitAsync(string userId, int maxSessions, CancellationToken ct)
    {
        if (maxSessions <= 0)
        {
            return;
        }

        var zKey = SessionKeys.UserSessions(userId);
        var count = await database.SortedSetLengthAsync(zKey);
        if (count <= maxSessions)
        {
            return;
        }

        var toRemove = await database.SortedSetRangeByRankAsync(zKey, 0, count - maxSessions - 1);
        foreach (var entry in toRemove)
        {
            if (!entry.IsNullOrEmpty)
            {
                await database.KeyDeleteAsync(SessionKeys.Session(entry!));
            }
        }

        await database.SortedSetRemoveRangeByRankAsync(zKey, 0, count - maxSessions - 1);
    }

    public Task RefreshSessionTtlAsync(string sid, TimeSpan ttl, CancellationToken ct)
    {
        return database.KeyExpireAsync(SessionKeys.Session(sid), ttl);
    }
}