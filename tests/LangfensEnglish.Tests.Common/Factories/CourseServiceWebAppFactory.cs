extern alias coursesvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using coursesvc::course_service.Infrastructure;
using CourseProgram = coursesvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class CourseServiceWebAppFactory : ServiceWebApplicationFactory<CourseProgram>
{
    public CourseServiceWebAppFactory(PostgresContainerFixture postgres)
        : base(postgres, "course_service_tests")
    {
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.CourseConnection] = ConnectionString,
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
        var db = scope.ServiceProvider.GetRequiredService<CourseDbContext>();
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync();
        }
    }
}
