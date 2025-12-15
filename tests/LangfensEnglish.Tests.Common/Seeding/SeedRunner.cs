using LangfensEnglish.Tests.Common.Fixtures;

namespace LangfensEnglish.Tests.Common.Seeding;

public class SeedRunner
{
    private readonly PostgresContainerFixture _postgres;

    public SeedRunner(PostgresContainerFixture postgres)
    {
        _postgres = postgres;
    }

    public virtual Task SeedAuthAsync(CancellationToken ct = default) => Task.CompletedTask;
    public virtual Task SeedCourseAsync(CancellationToken ct = default) => Task.CompletedTask;
    public virtual Task SeedVocabularyAsync(CancellationToken ct = default) => Task.CompletedTask;
    public virtual Task SeedExamAsync(CancellationToken ct = default) => Task.CompletedTask;
    public virtual Task SeedAttemptAsync(CancellationToken ct = default) => Task.CompletedTask;
}
