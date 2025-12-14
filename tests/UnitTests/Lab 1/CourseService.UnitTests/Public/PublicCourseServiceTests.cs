using course_service.Features.PublicEndpoint;

namespace CourseService.UnitTests.Public;

public class PublicCourseServiceTests
{
    [Fact]
    public async Task List_Should_Filter_By_Status_Category_Level()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = handle.Context;
        ctx.Courses.AddRange(
            new Course { Id = Guid.NewGuid(), Slug = "pub-1", Title = "Pub1", Status = CourseStatus.Published, Category = CourseCategories.IELTS_ACADEMIC, Level = CourseLevel.B1, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
            new Course { Id = Guid.NewGuid(), Slug = "draft-1", Title = "Draft", Status = CourseStatus.Draft, Category = CourseCategories.IELTS_ACADEMIC, Level = CourseLevel.B1, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow }
        );
        await ctx.SaveChangesAsync();

        var svc = new PublicEndpointService(ctx);

        var httpResult = await svc.GetPublicCourseService(
            category: CourseCategories.IELTS_ACADEMIC,
            level: CourseLevel.B1,
            status: CourseStatus.Published,
            token: CancellationToken.None,
            page: 1,
            pageSize: 10);

        var status = (httpResult as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        status.Should().Be(StatusCodes.Status200OK);
        var api = (httpResult as IValueHttpResult)?.Value as ApiResultDto;
        var list = api!.data as List<CourseListItemDto>;
        list.Should().NotBeNull();
        list!.Should().ContainSingle(c => c.Slug == "pub-1");
    }

    [Fact]
    public async Task GetCourseBySlug_Should_Return_Empty_List_When_Missing()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var svc = new PublicEndpointService(handle.Context);

        var result = await svc.GetCourseBySlug("missing", CancellationToken.None);
        var status = (result as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        var api = (result as IValueHttpResult)?.Value as ApiResultDto;

        status.Should().Be(StatusCodes.Status200OK);
        var data = api!.data.Should().BeAssignableTo<IReadOnlyList<CourseDetailDto>>().Subject;
        data.Should().BeEmpty();
    }

    [Fact]
    public async Task GetCourseBySlug_Should_Return_Detail_With_Lessons()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var ctx = handle.Context;
        var course = new Course
        {
            Id = Guid.NewGuid(),
            Slug = "ielts-a",
            Title = "IELTS A",
            Status = CourseStatus.Published,
            Category = CourseCategories.IELTS_ACADEMIC,
            Level = CourseLevel.B1,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        ctx.Courses.Add(course);
        ctx.Lessons.AddRange(
            new Lesson { Id = Guid.NewGuid(), CourseId = course.Id, Idx = 2, Title = "L2", DurationMin = 10 },
            new Lesson { Id = Guid.NewGuid(), CourseId = course.Id, Idx = 1, Title = "L1", DurationMin = 5 }
        );
        await ctx.SaveChangesAsync();

        var svc = new PublicEndpointService(ctx);
        var result = await svc.GetCourseBySlug("ielts-a", CancellationToken.None);

        var status = (result as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        var api = (result as IValueHttpResult)?.Value as ApiResultDto;
        status.Should().Be(StatusCodes.Status200OK);
        var list = api!.data.Should().BeAssignableTo<IReadOnlyList<CourseDetailDto>>().Subject.ToList();
        list.Should().ContainSingle();
        list[0].Slug.Should().Be("ielts-a");
        list[0].Lessons.Select(l => l.Idx).Should().Equal(1, 2);
    }
}
