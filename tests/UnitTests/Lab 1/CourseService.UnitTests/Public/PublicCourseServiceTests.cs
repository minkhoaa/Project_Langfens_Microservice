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
    public async Task GetCourseBySlug_Should_Return_NotFound_When_Missing()
    {
        await using var handle = SqliteInMemoryFactory.Create<CourseDbContext>();
        var svc = new PublicEndpointService(handle.Context);

        var result = await svc.GetCourseBySlug("missing", CancellationToken.None);
        var status = (result as IStatusCodeHttpResult)?.StatusCode ?? StatusCodes.Status200OK;
        var api = (result as IValueHttpResult)?.Value as ApiResultDto;

        status.Should().Be(StatusCodes.Status404NotFound);
        api!.isSuccess.Should().BeFalse();
    }
}
