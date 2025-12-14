namespace CourseService.UnitTests.User;

public class UserEnrollmentTests
{
    [Fact]
    public async Task EnrollCourse_Should_Return_NotFound_When_Course_Missing()
    {
        var userId = Guid.NewGuid();
        var courseId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        await using var conn = resources.Connection;
        var service = new UserEndpointService(ctx);

        var (status, payload) = ResultAssert.Api(
            await service.EnrollCourse(CancellationToken.None, courseId, userId));

        status.Should().Be(StatusCodes.Status404NotFound);
        payload.message.Should().Contain("Course not found");
    }

    [Fact]
    public async Task EnrollCourse_Should_Create_New_Enrollment()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        await using var conn = resources.Connection;

        var course = CourseTestData.AddCourse(ctx, "course-a");
        await ctx.SaveChangesAsync();

        var service = new UserEndpointService(ctx);
        var (status, payload) = ResultAssert.Api(
            await service.EnrollCourse(CancellationToken.None, course.Id, userId));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("Enroll successfully");
        payload.data.Should().BeOfType<EnrollResponse>();

        var enrollment = await ctx.Enrollments.SingleAsync();
        enrollment.UserId.Should().Be(userId);
        enrollment.Status.Should().Be(EnrollmentStatus.Active);
    }

    [Fact]
    public async Task EnrollCourse_Should_Reactivate_Existing_Enrollment()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        await using var conn = resources.Connection;

        var course = CourseTestData.AddCourse(ctx, "course-b");
        ctx.Enrollments.Add(new Enrollment
        {
            Id = Guid.NewGuid(),
            CourseId = course.Id,
            UserId = userId,
            Status = EnrollmentStatus.Cancelled,
            EnrolledAt = DateTime.UtcNow.AddDays(-5)
        });
        await ctx.SaveChangesAsync();

        var service = new UserEndpointService(ctx);
        var (status, payload) = ResultAssert.Api(
            await service.EnrollCourse(CancellationToken.None, course.Id, userId));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("Enroll successfully");
        var enrollment = await ctx.Enrollments.SingleAsync();
        enrollment.Status.Should().Be(EnrollmentStatus.Active);
    }
}
