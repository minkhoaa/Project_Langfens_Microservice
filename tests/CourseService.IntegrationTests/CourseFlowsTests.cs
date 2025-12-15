using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace CourseService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class CourseFlowsTests
{
    private const string SkipReason = "Pending authenticated flow and seed";
    private readonly CourseServiceWebAppFactory _factory;

    public CourseFlowsTests(CourseServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> EnrollCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(EnrollCases))]
    [Trait("Function", "Enroll in a course")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void EnrollCourse_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> EnrollmentListCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(EnrollmentListCases))]
    [Trait("Function", "View my enrollments")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void MyEnrollments_Cases(int caseId)
    {
    }
}
