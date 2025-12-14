namespace CourseService.UnitTests.User;

public class UserCompletionTests
{
    [Fact]
    public async Task CompleteCourse_Should_Return_NotFound_When_Lesson_Missing()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        var service = new UserEndpointService(ctx);

        var (status, payload) = ResultAssert.Api(
            await service.CompleteCourse(CancellationToken.None, Guid.NewGuid(), userId));

        status.Should()?.Be(StatusCodes.Status404NotFound);
        payload.message.Should()?.Contain("Lesson not found");
    }

    [Fact]
    public async Task CompleteCourse_Should_Forbid_When_User_Not_Enrolled()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;
        var course = CourseTestData.AddCourse(ctx, "course-c", lessonCount: 1);
        await ctx.SaveChangesAsync();

        var lesson = await ctx.Lessons.AsNoTracking().FirstAsync();
        var service = new UserEndpointService(ctx);
        var result = await service.CompleteCourse(CancellationToken.None, lesson.Id, userId);

        var statusCode = (result as IStatusCodeHttpResult)?.StatusCode ?? 0;
        statusCode.Should()?.Be(StatusCodes.Status403Forbidden);
    }

    [Fact]
    public async Task CompleteCourse_Should_Return_Existing_When_Already_Completed()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;

        var course = CourseTestData.AddCourse(ctx, "course-d", lessonCount: 1);
        await ctx.SaveChangesAsync();
        var lesson = await ctx.Lessons.AsNoTracking().FirstAsync();
        ctx.Enrollments.Add(new Enrollment
        {
            Id = Guid.NewGuid(),
            CourseId = course.Id,
            UserId = userId,
            Status = EnrollmentStatus.Active,
            EnrolledAt = DateTime.UtcNow
        });
        var completion = new LessonCompletion
        {
            Id = Guid.NewGuid(),
            LessonId = lesson.Id,
            UserId = userId,
            CompletedAt = DateTime.UtcNow.AddDays(-1)
        };
        ctx.LessonCompletions.Add(completion);
        await ctx.SaveChangesAsync();

        var service = new UserEndpointService(ctx);
        var (status, payload) = ResultAssert.Api(
            await service.CompleteCourse(CancellationToken.None, lesson.Id, userId));

        status.Should().Be(StatusCodes.Status200OK);
        payload.data.Should().BeOfType<CompleteResponse>();
        ((CompleteResponse)payload.data).CompletionId.Should().Be(completion.Id);
    }

    [Fact]
    public async Task CompleteCourse_Should_Create_New_Record_When_Eligible()
    {
        var userId = Guid.NewGuid();
        await using var resources = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = resources.Context;

        var course = CourseTestData.AddCourse(ctx, "course-e", lessonCount: 1);
        await ctx.SaveChangesAsync();
        var lesson = await ctx.Lessons.AsNoTracking().FirstAsync();
        ctx.Enrollments.Add(new Enrollment
        {
            Id = Guid.NewGuid(),
            CourseId = course.Id,
            UserId = userId,
            Status = EnrollmentStatus.Active,
            EnrolledAt = DateTime.UtcNow
        });
        await ctx.SaveChangesAsync();

        var service = new UserEndpointService(ctx);
        var (status, payload) = ResultAssert.Api(
            await service.CompleteCourse(CancellationToken.None, lesson.Id, userId));

        status.Should().Be(StatusCodes.Status200OK);
        var response = payload.data.Should().BeOfType<CompleteResponse>().Subject;
        var stored = await ctx.LessonCompletions.FindAsync(response.CompletionId);
        stored.Should().NotBeNull();
    }
}
