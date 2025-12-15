extern alias examsvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using examsvc::exam_service.Infrastructure.Persistence;
using ExamProgram = examsvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class ExamServiceWebAppFactory : ServiceWebApplicationFactory<ExamProgram>
{
    public ExamServiceWebAppFactory(PostgresContainerFixture postgres)
        : base(postgres, "exam_service_tests")
    {
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.ExamConnection] = ConnectionString,
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
        var db = scope.ServiceProvider.GetRequiredService<ExamDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
