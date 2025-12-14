using course_service.Features.AdminEndpoint;
using CourseService.UnitTests;

namespace CourseService.UnitTests.Admin;

public class AdminEndpointServiceTests
{
    [Fact]
    public async Task CreateCourse_Should_Persist_With_Default_Status()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = handle.Context;
        var svc = new AdminEndpointService(ctx);
        var request = new CreateCourseRequest(
            Slug: "ielts-course",
            Title: "IELTS Course",
            DescriptionMd: "desc",
            Category: CourseCategories.IELTS_ACADEMIC,
            Level: CourseLevel.B1,
            Status: null);

        var (status, payload) = ResultAssert.Api(await svc.CreateCourse(request, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var saved = await ctx.Courses.SingleAsync();
        saved.Slug.Should().Be("ielts-course");
        saved.Status.Should().Be(CourseStatus.Draft);
    }

    [Fact]
    public async Task AddLesson_Should_Shift_Existing_Indexes()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = handle.Context;
        var course = CourseTestData.AddCourse(ctx, "course-lesson", lessonCount: 2);
        await ctx.SaveChangesAsync();
        var svc = new AdminEndpointService(ctx);
        var request = new CreateLessonRequest("Lesson X", "content", 15, Idx: 2);

        var (status, payload) = ResultAssert.Api(await svc.AddLesson(request, course.Id, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        var ordered = await ctx.Lessons.Where(l => l.CourseId == course.Id).OrderBy(l => l.Idx).ToListAsync();
        ordered.Select(l => l.Idx).Should().Equal(1, 2, 3);
        ordered[1].Title.Should().Be("Lesson X");
    }
}
