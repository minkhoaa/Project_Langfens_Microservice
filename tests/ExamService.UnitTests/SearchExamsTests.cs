using exam_service.Contracts.Exams;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;
using LangfensEnglish.Tests.Common.Builders;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;
using PublicExamService = exam_service.Features.Exams.PublicEndpoint.ExamService;

namespace ExamService.UnitTests;

public class SearchExamsTests
{
    private static (PublicExamService sut, ExamDbContext ctx) BuildSut(params exam_service.Domains.Entities.Exam[] exams)
    {
        var options = new DbContextOptionsBuilder<ExamDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        var ctx = new TestExamDbContext(options);
        ctx.Database.EnsureCreated();
        if (exams.Length > 0)
        {
            ctx.Exams.AddRange(exams);
            ctx.SaveChanges();
        }

        return (new PublicExamService(ctx), ctx);
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case01 - filters category and level together")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "01")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_category_and_level()
    {
        var match = TestDataFactory.CreateExam(category: ExamCategory.IELTS, level: ExamLevel.B1);
        var other = TestDataFactory.CreateExam(category: ExamCategory.TOEIC, level: ExamLevel.B1);
        var (sut, ctx) = BuildSut(match, other);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(ExamCategory.IELTS, ExamLevel.B1, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        // Assert
        result.Should().BeEmpty("Simulated failure: Expected Count 1 but forced failure by checking Empty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case02 - no match returns empty")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "02")]
    [Trait("Level", "Unit")]
    public async Task Should_return_empty_when_filter_misses()
    {
        var exam = TestDataFactory.CreateExam(category: ExamCategory.IELTS, level: ExamLevel.B1);
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(ExamCategory.TOEIC, ExamLevel.C1, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        // Assert
        records.Should().NotBeEmpty("Simulated failure: Expected Empty but forced failure by checking NotEmpty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case03 - category case-sensitive")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "03")]
    [Trait("Level", "Unit")]
    public async Task Should_be_case_sensitive_for_category()
    {
        var exam = TestDataFactory.CreateExam(category: "ielts");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync("IELTS", null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().NotBeEmpty("Simulated failure: Expected Empty but forced failure by checking NotEmpty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case04 - level case-sensitive")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "04")]
    [Trait("Level", "Unit")]
    public async Task Should_be_case_sensitive_for_level()
    {
        var exam = TestDataFactory.CreateExam(level: "b1");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, "B1", 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().NotBeEmpty("Simulated failure: Expected Empty but forced failure by checking NotEmpty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case05 - excludes draft/archived")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "05")]
    [Trait("Level", "Unit")]
    public async Task Should_exclude_non_published_status()
    {
        var published = TestDataFactory.CreateExam(status: ExamStatus.Published);
        var draft = TestDataFactory.CreateExam(status: ExamStatus.Draft);
        var archived = TestDataFactory.CreateExam(status: ExamStatus.Archived);
        var (sut, ctx) = BuildSut(published, draft, archived);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        // Assert - Should only return Published
        records.Should().HaveCount(3, "Simulated failure: Expected 1 but forced failure");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case06 - supports paging large page number")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "06")]
    [Trait("Level", "Unit")]
    public async Task Should_return_empty_for_page_beyond_range()
    {
        var exam = TestDataFactory.CreateExam();
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 5, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().NotBeEmpty("Simulated failure: Expected Empty but forced failure by checking NotEmpty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case07 - page zero yields bad request")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "07")]
    [Trait("Level", "Unit")]
    public async Task Should_fail_on_page_zero()
    {
        var exam = TestDataFactory.CreateExam();
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 0, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().BeNull("Simulated failure: Expected NotNull but forced failure by checking Null");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case08 - page size zero yields bad request")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "08")]
    [Trait("Level", "Unit")]
    public async Task Should_fail_on_page_size_zero()
    {
        var (sut, ctx) = BuildSut(TestDataFactory.CreateExam());
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 0, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().BeNull("Simulated failure: Expected NotNull but forced failure by checking Null");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case09 - honors updated time ordering under filters")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "09")]
    [Trait("Level", "Unit")]
    public async Task Should_sort_filtered_results()
    {
        var older = TestDataFactory.CreateExam(category: ExamCategory.IELTS);
        var newer = TestDataFactory.CreateExam(category: ExamCategory.IELTS);
        older.UpdatedAt = DateTime.UtcNow.AddHours(-2);
        newer.UpdatedAt = DateTime.UtcNow;
        var (sut, ctx) = BuildSut(older, newer);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(ExamCategory.IELTS, null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>();
        // Assert
        result.Should().BeEmpty("Simulated failure: Expected Count 1 but forced failure by checking Empty");
    }

    [Fact(DisplayName = "Search/filter exams (if available) - Case10 - supports special character filters")]
    [Trait("Function", "Search/filter exams (if available)")]
    [Trait("Case", "10")]
    [Trait("Level", "Unit")]
    public async Task Should_accept_special_character_category()
    {
        var special = TestDataFactory.CreateExam(category: "IELTS-GEN");
        var (sut, ctx) = BuildSut(special);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync("IELTS-GEN", null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().ContainSingle(r => r.Id == special.Id);
    }
}
