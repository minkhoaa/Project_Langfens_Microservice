extern alias gatewaysvc;

using LangfensEnglish.Tests.Common.Fixtures;
using LangfensEnglish.Tests.Common.Utils;
using GatewayProgram = gatewaysvc::Program;

namespace LangfensEnglish.Tests.Common.Factories;

public class GatewayWebAppFactory : ServiceWebApplicationFactory<GatewayProgram>
{
    public GatewayWebAppFactory(PostgresContainerFixture postgres)
        : base(postgres, "gateway_tests")
    {
    }

    protected override Dictionary<string, string?> BuildConfigurationOverrides()
    {
        return new Dictionary<string, string?>
        {
            [TestEnvKeys.JwtIssuer] = "TestIssuer",
            [TestEnvKeys.JwtAudience] = "TestAudience",
            [TestEnvKeys.JwtSignKey] = "test-signing-key-1234567890",
            [TestEnvKeys.JwtAccessLifetime] = "300",
            ["ASPNETCORE_ENVIRONMENT"] = "Testing"
        };
    }

    protected override Task RunMigrationsAsync(IServiceProvider services) => Task.CompletedTask;
}
