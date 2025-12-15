using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace CourseService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class PublicCoursesTests
{
    private const string SkipReason = "Pending data seed for course service";
    private readonly CourseServiceWebAppFactory _factory;

    public PublicCoursesTests(CourseServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> BrowseCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(BrowseCases))]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void BrowseCourses_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> DetailCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(DetailCases))]
    [Trait("Function", "Course detail")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void CourseDetail_Cases(int caseId)
    {
    }
}
