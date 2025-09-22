using auth_service.Data;

namespace auth_service.Infrastructure.Persistence;

public interface ISessionRepository
{
    Task<SessionEntity?> FindAsync(string userId, string deviceId, CancellationToken ct);
    Task<SessionEntity> UpsertAsync(SessionEntity entity, CancellationToken ct);
    Task SaveChangesAsync(CancellationToken ct);
}
