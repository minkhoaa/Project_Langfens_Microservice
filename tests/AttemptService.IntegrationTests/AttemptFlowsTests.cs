using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace AttemptService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AttemptFlowsTests
{
    private const string SkipReason = "Pending exam snapshot fakes and seed";
    private readonly AttemptServiceWebAppFactory _factory;

    public AttemptFlowsTests(AttemptServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> StartCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(StartCases))]
    [Trait("Function", "Start exam attempt")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void StartAttempt_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> SaveCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SaveCases))]
    [Trait("Function", "Save answers during attempt")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void SaveAnswers_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> SubmitCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SubmitCases))]
    [Trait("Function", "Submit attempt")]
    [Trait("Case", "03")]
    [Trait("Level", "Integration")]
    public void SubmitAttempt_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> HistoryCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(HistoryCases))]
    [Trait("Function", "View attempt history")]
    [Trait("Case", "04")]
    [Trait("Level", "Integration")]
    public void AttemptHistory_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> ResultCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(ResultCases))]
    [Trait("Function", "View attempt result detail")]
    [Trait("Case", "05")]
    [Trait("Level", "Integration")]
    public void AttemptResult_Cases(int caseId)
    {
    }
}
