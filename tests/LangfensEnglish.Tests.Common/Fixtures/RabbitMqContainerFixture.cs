using Testcontainers.RabbitMq;
using Xunit;

namespace LangfensEnglish.Tests.Common.Fixtures;

public class RabbitMqContainerFixture : IAsyncLifetime
{
    private readonly RabbitMqContainer _container;
    private readonly string _username = "guest";
    private readonly string _password = "guest";
    private readonly string _virtualHost = "/";

    public RabbitMqContainerFixture()
    {
        _container = new RabbitMqBuilder()
            .WithImage("rabbitmq:3.13-management-alpine")
            .WithUsername(_username)
            .WithPassword(_password)
            .WithCleanUp(true)
            .Build();
    }

    public string Host => "localhost";
    public ushort Port => (ushort)_container.GetMappedPublicPort(5672);
    public string Username => _username;
    public string Password => _password;
    public string VirtualHost => _virtualHost;
    public string ConnectionString => _container.GetConnectionString();

    public Task InitializeAsync() => _container.StartAsync();

    public Task DisposeAsync() => _container.DisposeAsync().AsTask();
}
