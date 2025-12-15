using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace AttemptService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminAttemptMonitorTests
{
    private const string SkipReason = "Pending admin auth/seed for attempt service";
    private readonly AttemptServiceWebAppFactory _factory;

    public AdminAttemptMonitorTests(AttemptServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> MonitorCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(MonitorCases))]
    [Trait("Function", "Admin monitor attempts list")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void MonitorAttempts_Cases(int caseId)
    {
    }
}
