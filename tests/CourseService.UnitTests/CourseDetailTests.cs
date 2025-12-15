using course_service.Contracts;
using course_service.Features.PublicEndpoint;
using course_service.Infrastructure;
using FluentAssertions;
using LangfensEnglish.Tests.Common.Builders;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Course.Enums;

namespace CourseService.UnitTests;

public class CourseDetailTests
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

    [Fact(DisplayName = "View course detail (by slug/id) - Case01 - returns course with lessons")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "01")]
    [Trait("Level", "Unit")]
    public async Task Should_return_course_detail()
    {
        var course = TestDataFactory.CreateCourse(slug: "c-1", lessons: 2);
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("c-1", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.ToList();
        items.Should().ContainSingle();
        items.Single().Lessons.Should().HaveCount(2);
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case02 - not found for unknown slug")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "02")]
    [Trait("Level", "Unit")]
    public async Task Should_return_not_found_when_slug_missing()
    {
        var course = TestDataFactory.CreateCourse(slug: "known");
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("unknown", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>()
            .Subject.Should().BeEmpty();
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case03 - trims not applied for whitespace")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "03")]
    [Trait("Level", "Unit")]
    public async Task Should_fail_when_slug_has_whitespace()
    {
        var course = TestDataFactory.CreateCourse(slug: "whitespace");
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug(" whitespace ", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>()
            .Subject.Should().BeEmpty();
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case04 - lesson ordering by idx")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "04")]
    [Trait("Level", "Unit")]
    public async Task Should_order_lessons_by_idx()
    {
        var course = TestDataFactory.CreateCourse(slug: "ordered", lessons: 2);
        course.Lessons.First().Idx = 2;
        course.Lessons.Last().Idx = 1;
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("ordered", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.Single();
        detail.Lessons.Select(x => x.Idx).Should().ContainInOrder(2, 1);
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case05 - includes metadata")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "05")]
    [Trait("Level", "Unit")]
    public async Task Should_include_metadata()
    {
        var course = TestDataFactory.CreateCourse(slug: "meta", category: CourseCategories.ACADEMIC_ENGLISH, level: CourseLevel.C1, status: CourseStatus.Published);
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("meta", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.Single();
        detail.Category.Should().Be(CourseCategories.ACADEMIC_ENGLISH);
        detail.Level.Should().Be(CourseLevel.C1);
        detail.Status.Should().Be(CourseStatus.Published);
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case06 - handles no lessons")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "06")]
    [Trait("Level", "Unit")]
    public async Task Should_allow_no_lessons()
    {
        var course = TestDataFactory.CreateCourse(slug: "empty", lessons: 0);
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("empty", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.Single();
        detail.Lessons.Should().BeEmpty();
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case07 - only matching slug returned")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "07")]
    [Trait("Level", "Unit")]
    public async Task Should_only_return_matching_slug()
    {
        var c1 = TestDataFactory.CreateCourse(slug: "one");
        var c2 = TestDataFactory.CreateCourse(slug: "two");
        var (sut, ctx) = BuildSut(c1, c2);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("two", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var items = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.ToList();
        items.Should().ContainSingle(x => x.Slug == "two");
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case08 - no data returns not found")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "08")]
    [Trait("Level", "Unit")]
    public async Task Should_not_found_when_database_empty()
    {
        var (sut, ctx) = BuildSut();
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("missing", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>()
            .Subject.Should().BeEmpty();
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case09 - case sensitivity for slug")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "09")]
    [Trait("Level", "Unit")]
    public async Task Should_be_case_sensitive()
    {
        var course = TestDataFactory.CreateCourse(slug: "lower");
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("LOWER", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>()
            .Subject.Should().BeEmpty();
    }

    [Fact(DisplayName = "View course detail (by slug/id) - Case10 - handles null description")]
    [Trait("Function", "View course detail (by slug/id)")]
    [Trait("Case", "10")]
    [Trait("Level", "Unit")]
    public async Task Should_allow_null_description()
    {
        var course = TestDataFactory.CreateCourse(slug: "null-desc");
        course.DescriptionMd = null;
        var (sut, ctx) = BuildSut(course);
        await using var _ = ctx;

        var result = await sut.GetCourseBySlug("null-desc", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<IEnumerable<CourseDetailDto>>().Subject.Single();
        detail.DescriptionMd.Should().BeNull();
    }
}
