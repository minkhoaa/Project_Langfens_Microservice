using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace AttemptService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminSpeakingFlowsTests
{
    private const string SkipReason = "Pending admin auth/seed for speaking service";
    private readonly SpeakingServiceWebAppFactory _factory;

    public AdminSpeakingFlowsTests(SpeakingServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> SpeakingAdminCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SpeakingAdminCases))]
    [Trait("Function", "Admin manage speaking exams")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void AdminSpeaking_Cases(int caseId)
    {
    }
}
