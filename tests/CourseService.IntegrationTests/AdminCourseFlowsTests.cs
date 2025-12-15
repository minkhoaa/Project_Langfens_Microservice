using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace CourseService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AdminCourseFlowsTests
{
    private const string SkipReason = "Pending admin auth/seed for course service";
    private readonly CourseServiceWebAppFactory _factory;

    public AdminCourseFlowsTests(CourseServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> CourseAdminCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(CourseAdminCases))]
    [Trait("Function", "Admin manage courses & lessons")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void AdminCourseManagement_Cases(int caseId)
    {
    }
}
