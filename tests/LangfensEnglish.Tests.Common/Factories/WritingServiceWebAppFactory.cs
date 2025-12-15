extern alias writingsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using writingsvc::writing_service.Infrastructure.Persistence;
using WritingProgram = writingsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class WritingServiceWebAppFactory : ServiceWebApplicationFactory<WritingProgram>
{
    private readonly RabbitMqContainerFixture _rabbitMq;

    public WritingServiceWebAppFactory(PostgresContainerFixture postgres, RabbitMqContainerFixture rabbitMq)
        : base(postgres, "writing_service_tests")
    {
        _rabbitMq = rabbitMq;
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.WritingConnection] = ConnectionString,
            [TestEnvKeys.JwtIssuer] = "TestIssuer",
            [TestEnvKeys.JwtAudience] = "TestAudience",
            [TestEnvKeys.JwtSignKey] = "test-signing-key-1234567890",
            [TestEnvKeys.JwtAccessLifetime] = "300",
            ["RABBITMQ__HOST"] = _rabbitMq.Host,
            ["RABBITMQ__PORT"] = _rabbitMq.Port.ToString(),
            ["RABBITMQ__USERNAME"] = _rabbitMq.Username,
            ["RABBITMQ__PASSWORD"] = _rabbitMq.Password,
            ["RABBITMQ__VHOST"] = _rabbitMq.VirtualHost,
            ["GEMINI__APIKEY"] = "fake-gemini-api-key",
            ["GEMINI__MODEL"] = "gemini-2.5-flash-lite",
            ["GEMINI__PROVIDER"] = "google",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override async Task RunMigrationsAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<WritingDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
