using Microsoft.EntityFrameworkCore.Diagnostics;

namespace AttemptService.UnitTests;

internal static class AttemptDbContextFactory
{
    public static AttemptDbContext Create()
    {
        var options = new DbContextOptionsBuilder<AttemptDbContext>()
            .UseInMemoryDatabase($"attempt-tests-{Guid.NewGuid()}")
            .EnableSensitiveDataLogging()
            .EnableDetailedErrors()
            .ConfigureWarnings(b => b.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;
        return new AttemptDbContextTest(options);
    }
}
