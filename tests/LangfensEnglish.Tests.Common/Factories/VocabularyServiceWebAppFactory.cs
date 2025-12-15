extern alias vocsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using vocsvc::vocabulary_service.Infrastructure.Persistence;
using VocabularyProgram = vocsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class VocabularyServiceWebAppFactory : ServiceWebApplicationFactory<VocabularyProgram>
{
    public VocabularyServiceWebAppFactory(PostgresContainerFixture postgres)
        : base(postgres, "vocabulary_service_tests")
    {
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.VocabularyConnection] = ConnectionString,
            [TestEnvKeys.JwtIssuer] = "TestIssuer",
            [TestEnvKeys.JwtAudience] = "TestAudience",
            [TestEnvKeys.JwtSignKey] = "test-signing-key-1234567890",
            [TestEnvKeys.JwtAccessLifetime] = "300",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override async Task RunMigrationsAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<VocabularyDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
