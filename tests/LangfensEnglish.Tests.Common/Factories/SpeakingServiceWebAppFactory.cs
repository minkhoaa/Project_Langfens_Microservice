extern alias speakingsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using speakingsvc::speaking_service.Infrastructure.Persistence;
using SpeakingProgram = speakingsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class SpeakingServiceWebAppFactory : ServiceWebApplicationFactory<SpeakingProgram>
{
    private readonly RabbitMqContainerFixture _rabbitMq;

    public SpeakingServiceWebAppFactory(PostgresContainerFixture postgres, RabbitMqContainerFixture rabbitMq)
        : base(postgres, "speaking_service_tests")
    {
        _rabbitMq = rabbitMq;
        EnsureWhisperModelPlaceholder();
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.SpeakingConnection] = ConnectionString,
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
            ["CLOUDINARY_API_KEY"] = "test",
            ["CLOUDINARY_API_SECRET"] = "test",
            ["CLOUDINARY_CLOUD_NAME"] = "test",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override async Task RunMigrationsAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<SpeakingDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }

    private static void EnsureWhisperModelPlaceholder()
    {
        var modelDir = Path.Combine(AppContext.BaseDirectory, "Models");
        Directory.CreateDirectory(modelDir);
        var modelPath = Path.Combine(modelDir, "ggml-tiny.en.bin");
        if (!File.Exists(modelPath))
        {
            File.WriteAllText(modelPath, "placeholder");
        }
    }
}
