using course_service.Features.PublicEndpoint;
using course_service.Contracts;
using course_service.Infrastructure;
using FluentAssertions;
using LangfensEnglish.Tests.Common.Builders;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace CourseService.UnitTests;

public class BrowseCoursesListTests
{
    private static (PublicEndpointService sut, CourseDbContext ctx) BuildSut(params course_service.Domains.Entities.Course[] courses)
    {
        var options = new DbContextOptionsBuilder<CourseDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        var ctx = new CourseDbContext(options);
        ctx.Database.EnsureCreated();
        if (courses.Length > 0)
        {
            ctx.Courses.AddRange(courses);
            ctx.SaveChanges();
        }

        return (new PublicEndpointService(ctx), ctx);
    }

    [Fact(DisplayName = "Browse courses list - Case01 - returns all published")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "01")]
    [Trait("Level", "Unit")]
    public async Task Should_return_all_courses()
    {
        var c1 = TestDataFactory.CreateCourse(status: CourseStatus.Published);
        var c2 = TestDataFactory.CreateCourse(status: CourseStatus.Published);
        var (sut, ctx) = BuildSut(c1, c2);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().HaveCount(2);
    }

    [Fact(DisplayName = "Browse courses list - Case02 - filters by category")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "02")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_category()
    {
        var general = TestDataFactory.CreateCourse(category: CourseCategories.GENERAL_ENGLISH);
        var business = TestDataFactory.CreateCourse(category: CourseCategories.BUSINESS_ENGLISH);
        var (sut, ctx) = BuildSut(general, business);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(CourseCategories.BUSINESS_ENGLISH, null, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Id == business.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case03 - filters by level")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "03")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_level()
    {
        var beginner = TestDataFactory.CreateCourse(level: CourseLevel.B1);
        var advanced = TestDataFactory.CreateCourse(level: CourseLevel.C1);
        var (sut, ctx) = BuildSut(beginner, advanced);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, CourseLevel.C1, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Id == advanced.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case04 - filters by status")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "04")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_status()
    {
        var published = TestDataFactory.CreateCourse(status: CourseStatus.Published);
        var draft = TestDataFactory.CreateCourse(status: CourseStatus.Draft);
        var (sut, ctx) = BuildSut(published, draft);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, CourseStatus.Published, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Id == published.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case05 - clamps page and size")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "05")]
    [Trait("Level", "Unit")]
    public async Task Should_clamp_page_and_size()
    {
        var course = TestDataFactory.CreateCourse();
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, null, CancellationToken.None, page: 0, pageSize: 0);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Id == course.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case06 - invalid category ignored")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "06")]
    [Trait("Level", "Unit")]
    public async Task Should_ignore_invalid_category_filter()
    {
        var course = TestDataFactory.CreateCourse(category: CourseCategories.GENERAL_ENGLISH);
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService("UNKNOWN", null, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject;
        items.Should().ContainSingle(x => x.Id == course.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case07 - invalid level ignored")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "07")]
    [Trait("Level", "Unit")]
    public async Task Should_ignore_invalid_level_filter()
    {
        var course = TestDataFactory.CreateCourse(level: CourseLevel.B1);
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, "INVALID", null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject;
        items.Should().ContainSingle(x => x.Id == course.Id);
    }

    [Fact(DisplayName = "Browse courses list - Case08 - sorting by title asc")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "08")]
    [Trait("Level", "Unit")]
    public async Task Should_sort_by_title()
    {
        var a = TestDataFactory.CreateCourse();
        a.Title = "A course";
        var b = TestDataFactory.CreateCourse();
        b.Title = "B course";
        var (sut, ctx) = BuildSut(b, a);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Select(x => x.Title).Should().ContainInOrder("A course", "B course");
    }

    [Fact(DisplayName = "Browse courses list - Case09 - empty store returns ok")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "09")]
    [Trait("Level", "Unit")]
    public async Task Should_return_empty_when_no_courses()
    {
        var (sut, ctx) = BuildSut();
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, null, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>()
            .Subject.Should().BeEmpty();
    }

    [Fact(DisplayName = "Browse courses list - Case10 - respects page boundaries")]
    [Trait("Function", "Browse courses list")]
    [Trait("Case", "10")]
    [Trait("Level", "Unit")]
    public async Task Should_return_correct_page()
    {
        var c1 = TestDataFactory.CreateCourse();
        var c2 = TestDataFactory.CreateCourse();
        c1.Title = "Alpha";
        c2.Title = "Beta";
        var (sut, ctx) = BuildSut(c1, c2);
        await using var _ = ctx;

        var result = await sut.GetPublicCourseService(null, null, null, CancellationToken.None, page: 2, pageSize: 1);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseListItemDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Id == c2.Id);
    }
}
