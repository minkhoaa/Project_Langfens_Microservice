using auth_service.Data;
using auth_service.Models;

namespace auth_service.Infrastructure.Persistence;

public interface ISessionRepository
{
    Task<SessionEntity?> FindAsync(string userId, string deviceId, CancellationToken ct);
    Task<SessionEntity> UpsertAsync(SessionEntity entity, CancellationToken ct);
    Task SaveChangesAsync(CancellationToken ct);
}

public class SessionRepository : ISessionRepository
{
    private readonly AuthDbContext _dbContext;

    public SessionRepository(AuthDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<SessionEntity?> FindAsync(string userId, string deviceId, CancellationToken ct)
    {
        return await _dbContext.Sessions.FindAsync(new object[] { userId, deviceId }, ct);
    }

    public async Task<SessionEntity> UpsertAsync(SessionEntity entity, CancellationToken ct)
    {
        var existing = await FindAsync(entity.UserId, entity.DeviceId, ct);
        if (existing is null)
        {
            await _dbContext.Sessions.AddAsync(entity, ct);
            return entity;
        }

        existing.PrevJti = existing.Jti;
        existing.Jti = entity.Jti;
        existing.Exp = entity.Exp;
        existing.LastSeen = entity.LastSeen;
        existing.Ua = entity.Ua;
        existing.Ip = entity.Ip;
        existing.RevokedAt = null;
        return existing;
    }

    public Task SaveChangesAsync(CancellationToken ct) => _dbContext.SaveChangesAsync(ct);
}