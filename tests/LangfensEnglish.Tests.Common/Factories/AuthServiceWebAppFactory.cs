extern alias authsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using authsvc::auth_service.Infrastructure.Persistence;
using AuthProgram = authsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class AuthServiceWebAppFactory : ServiceWebApplicationFactory<AuthProgram>
{
    private readonly RedisContainerFixture _redis;
    private readonly RabbitMqContainerFixture _rabbitMq;

    public AuthServiceWebAppFactory(
        PostgresContainerFixture postgres,
        RedisContainerFixture redis,
        RabbitMqContainerFixture rabbitMq)
        : base(postgres, "auth_service_tests")
    {
        _redis = redis;
        _rabbitMq = rabbitMq;
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.AuthConnection] = ConnectionString,
            [TestEnvKeys.RedisConnection] = _redis.ConnectionString,
            [TestEnvKeys.JwtIssuer] = "TestIssuer",
            [TestEnvKeys.JwtAudience] = "TestAudience",
            [TestEnvKeys.JwtSignKey] = "test-signing-key-1234567890",
            [TestEnvKeys.JwtAccessLifetime] = "300",
            ["JwtSettings__RsaPrivateKeyPem"] = "-----BEGIN RSA PRIVATE KEY-----TEST-----END RSA PRIVATE KEY-----",
            ["JwtSettings__KeyId"] = "testing-key",
            ["RABBITMQ__HOST"] = _rabbitMq.Host,
            ["RABBITMQ__PORT"] = _rabbitMq.Port.ToString(),
            ["RABBITMQ__USERNAME"] = _rabbitMq.Username,
            ["RABBITMQ__PASSWORD"] = _rabbitMq.Password,
            ["RABBITMQ__VHOST"] = _rabbitMq.VirtualHost,
            ["RABBITMQ__USESSL"] = "false",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override async Task RunMigrationsAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
