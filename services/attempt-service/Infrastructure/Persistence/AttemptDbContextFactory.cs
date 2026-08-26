using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace attempt_service.Infrastructure.Persistence;

public sealed class AttemptDbContextFactory : IDesignTimeDbContextFactory<AttemptDbContext>
{
    public AttemptDbContext CreateDbContext(string[] args)
    {
        var conn = Environment.GetEnvironmentVariable("ConnectionStrings__attempt-db")
            ?? "Host=localhost;Port=5435;Database=attempt-db;Username=postgres;Password=postgres";
        var opts = new DbContextOptionsBuilder<AttemptDbContext>()
            .UseNpgsql(conn)
            .Options;
        return new AttemptDbContext(opts);
    }
}