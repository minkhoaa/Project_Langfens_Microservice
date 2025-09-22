using System;
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

public class SessionStore : ISessionStore
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);
    private readonly IDatabase _database;

    public SessionStore(IDatabase database)
    {
        _database = database;
    }

    public Task StoreSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct)
    {
        var value = JsonSerializer.Serialize(record, SerializerOptions);
        return _database.StringSetAsync(SessionKeys.Session(record.Sid), value, ttl);
    }

    public async Task<SessionRecord?> GetSessionAsync(string sid, CancellationToken ct)
    {
        var value = await _database.StringGetAsync(SessionKeys.Session(sid));
        if (value.IsNullOrEmpty)
        {
            return null;
        }

        return JsonSerializer.Deserialize<SessionRecord>(value!, SerializerOptions);
    }

    public async Task RemoveSessionAsync(SessionRecord record, CancellationToken ct)
    {
        await _database.KeyDeleteAsync(SessionKeys.Session(record.Sid));
        await _database.SortedSetRemoveAsync(SessionKeys.UserSessions(record.UserId), record.Sid);
        if (!string.IsNullOrWhiteSpace(record.DeviceId))
        {
            await _database.KeyDeleteAsync(SessionKeys.UserDevice(record.UserId, record.DeviceId!));
        }
    }

    public async Task SetDeviceSessionAsync(SessionRecord record, TimeSpan ttl, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(record.DeviceId))
        {
            return;
        }

        var deviceKey = SessionKeys.UserDevice(record.UserId, record.DeviceId!);
        var oldSid = await _database.StringGetAsync(deviceKey);
        if (!oldSid.IsNullOrEmpty)
        {
            if (!string.Equals(oldSid!, record.Sid, StringComparison.Ordinal))
            {
                await _database.KeyDeleteAsync(SessionKeys.Session(oldSid!));
            }
            await _database.SortedSetRemoveAsync(SessionKeys.UserSessions(record.UserId), oldSid!);
        }

        await _database.StringSetAsync(deviceKey, record.Sid, ttl);
        await _database.SortedSetAddAsync(SessionKeys.UserSessions(record.UserId), record.Sid,
            DateTimeOffset.UtcNow.ToUnixTimeSeconds());
    }

    public async Task EnsureSessionLimitAsync(string userId, int maxSessions, CancellationToken ct)
    {
        if (maxSessions <= 0)
        {
            return;
        }

        var zKey = SessionKeys.UserSessions(userId);
        var count = await _database.SortedSetLengthAsync(zKey);
        if (count <= maxSessions)
        {
            return;
        }

        var toRemove = await _database.SortedSetRangeByRankAsync(zKey, 0, count - maxSessions - 1);
        foreach (var entry in toRemove)
        {
            if (!entry.IsNullOrEmpty)
            {
                await _database.KeyDeleteAsync(SessionKeys.Session(entry!));
            }
        }

        await _database.SortedSetRemoveRangeByRankAsync(zKey, 0, count - maxSessions - 1);
    }

    public Task RefreshSessionTtlAsync(string sid, TimeSpan ttl, CancellationToken ct)
    {
        return _database.KeyExpireAsync(SessionKeys.Session(sid), ttl);
    }
}
