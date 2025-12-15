using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace AttemptService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminWritingFlowsTests
{
    private const string SkipReason = "Pending admin auth/seed for writing service";
    private readonly WritingServiceWebAppFactory _factory;

    public AdminWritingFlowsTests(WritingServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> WritingAdminCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(WritingAdminCases))]
    [Trait("Function", "Admin manage writing exams")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void AdminWriting_Cases(int caseId)
    {
    }
}
