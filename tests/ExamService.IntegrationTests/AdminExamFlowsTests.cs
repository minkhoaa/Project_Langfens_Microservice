using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace ExamService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminExamFlowsTests
{
    private const string SkipReason = "Pending admin auth/seed for exam service";
    private readonly ExamServiceWebAppFactory _factory;

    public AdminExamFlowsTests(ExamServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> CatalogCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(CatalogCases))]
    [Trait("Function", "Admin manage exam catalog")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void AdminExamCatalog_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> StructureCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(StructureCases))]
    [Trait("Function", "Admin edit exam structure")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void AdminExamStructure_Cases(int caseId)
    {
    }
}
