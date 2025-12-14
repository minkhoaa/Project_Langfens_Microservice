namespace CourseService.UnitTests.User;

public class UserProgressTests
{
    [Fact]
    public async Task GetMyProgress_Should_Return_Empty_When_No_Enrollment()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        var service = new UserEndpointService(ctx);

        var (status, payload) = ResultAssert.Api(
            await service.GetMyProgress(userId, CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        var dto = payload.data.Should().BeOfType<MyProgressDto>().Subject;
        dto.Courses.Should().BeEmpty();
    }

    [Fact]
    public async Task GetMyProgress_Should_Aggregate_Percentages()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;

        var course = CourseTestData.AddCourse(ctx, "course-progress", lessonCount: 3);
        await ctx.SaveChangesAsync();
        var lessons = await ctx.Lessons.Where(x => x.CourseId == course.Id).OrderBy(x => x.Idx).ToListAsync();
        ctx.Enrollments.Add(new Enrollment
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CourseId = course.Id,
            Status = EnrollmentStatus.Active,
            EnrolledAt = DateTime.UtcNow
        });
        ctx.LessonCompletions.Add(new LessonCompletion
        {
            Id = Guid.NewGuid(),
            LessonId = lessons[0].Id,
            UserId = userId,
            CompletedAt = DateTime.UtcNow
        });
        await ctx.SaveChangesAsync();

        var service = new UserEndpointService(ctx);
        var (status, payload) = ResultAssert.Api(
            await service.GetMyProgress(userId, CancellationToken.None));

        status.Should()?.Be(StatusCodes.Status200OK);
        var dto = payload.data.Should()?.BeOfType<MyProgressDto>()?.Subject;
        dto.Courses.Should().HaveCount(1);
        dto.Courses[0].TotalLessons.Should()?.Be(3);
        dto.Courses[0].CompletedLessons.Should()?.Be(1);
        (dto.Courses[0].Percent.Should() ?? throw new InvalidOperationException()).BeApproximately(33.33, 0.01);
    }
}
