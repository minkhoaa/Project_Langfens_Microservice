using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace ExamService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class InternalFlowsTests
{
    private const string SkipReason = "Pending internal delivery snapshot fakes";
    private readonly ExamServiceWebAppFactory _factory;

    public InternalFlowsTests(ExamServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> SnapshotCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SnapshotCases))]
    [Trait("Function", "Internal fetch delivery snapshot")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void InternalSnapshot_SuccessCases(int caseId)
    {
    }

    public static IEnumerable<object[]> SnapshotErrorCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SnapshotErrorCases))]
    [Trait("Function", "Internal fetch delivery snapshot error")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void InternalSnapshot_ErrorCases(int caseId)
    {
    }
}
