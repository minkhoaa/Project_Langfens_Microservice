using Testcontainers.Redis;
using Xunit;

namespace LangfensEnglish.Tests.Common.Fixtures;

public class RedisContainerFixture : IAsyncLifetime
{
    private readonly RedisContainer _container;

    public RedisContainerFixture()
    {
        _container = new RedisBuilder()
            .WithImage("redis:7-alpine")
            .WithCleanUp(true)
            .Build();
    }

    public string ConnectionString => _container.GetConnectionString();

    public Task InitializeAsync() => _container.StartAsync();

    public Task DisposeAsync() => _container.DisposeAsync().AsTask();
}
