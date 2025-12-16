using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace ExamService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class PublicExamsTests
{
    private const string SkipReason = "Pending data seed for exam service";
    private readonly ExamServiceWebAppFactory _factory;

    public PublicExamsTests(ExamServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> ListCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory]
    [MemberData(nameof(ListCases))]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void BrowseExams_ListCases(int caseId)
    {
         if (caseId <= 2) Assert.True(false, "Simulated Exam Integration Failure for Demo");
    }

    public static IEnumerable<object[]> DetailCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(DetailCases))]
    [Trait("Function", "Exam detail")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void ExamDetail_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> SearchCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(SearchCases))]
    [Trait("Function", "Search/filter exams")]
    [Trait("Case", "03")]
    [Trait("Level", "Integration")]
    public void SearchExams_Cases(int caseId)
    {
    }
}
