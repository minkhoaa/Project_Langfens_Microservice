extern alias attemptsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using attemptsvc::attempt_service.Infrastructure.Persistence;
using AttemptProgram = attemptsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class AttemptServiceWebAppFactory : ServiceWebApplicationFactory<AttemptProgram>
{
    private readonly RabbitMqContainerFixture _rabbitMq;

    public AttemptServiceWebAppFactory(PostgresContainerFixture postgres, RabbitMqContainerFixture rabbitMq)
        : base(postgres, "attempt_service_tests")
    {
        _rabbitMq = rabbitMq;
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.AttemptConnection] = ConnectionString,
            [TestEnvKeys.JwtIssuer] = "TestIssuer",
            [TestEnvKeys.JwtAudience] = "TestAudience",
            [TestEnvKeys.JwtSignKey] = "test-signing-key-1234567890",
            [TestEnvKeys.JwtAccessLifetime] = "300",
            ["RABBITMQ__HOST"] = _rabbitMq.Host,
            ["RABBITMQ__PORT"] = _rabbitMq.Port.ToString(),
            ["RABBITMQ__USERNAME"] = _rabbitMq.Username,
            ["RABBITMQ__PASSWORD"] = _rabbitMq.Password,
            ["RABBITMQ__VHOST"] = _rabbitMq.VirtualHost,
            ["EXAMSERVICE__EXAM__ADDRESS"] = "http://localhost",
            ["EXAMSERVICE__INTERNAL__API__KEY"] = "internal-test-key",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override async Task RunMigrationsAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AttemptDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
