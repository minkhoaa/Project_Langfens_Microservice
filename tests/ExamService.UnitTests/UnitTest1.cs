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

public class BrowseExamsListTests
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

    [Fact(DisplayName = "Browse exams list - Case01 - published only")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "01")]
    [Trait("Level", "Unit")]
    public async Task Should_return_only_published_items()
    {
        var published = TestDataFactory.CreateExam(status: ExamStatus.Published);
        var draft = TestDataFactory.CreateExam(status: ExamStatus.Draft);
        var (sut, ctx) = BuildSut(published, draft);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.isSuccess.Should().BeTrue();
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().HaveCount(1);
        records.Single().Id.Should().Be(published.Id);
    }

    [Fact(DisplayName = "Browse exams list - Case02 - filters by category")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "02")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_category()
    {
        var ielts = TestDataFactory.CreateExam(category: ExamCategory.IELTS);
        var toeic = TestDataFactory.CreateExam(category: ExamCategory.TOEIC);
        var (sut, ctx) = BuildSut(ielts, toeic);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(ExamCategory.IELTS, null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().ContainSingle(r => r.Id == ielts.Id);
    }

    [Fact(DisplayName = "Browse exams list - Case03 - filters by level")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "03")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_level()
    {
        var b1 = TestDataFactory.CreateExam(level: ExamLevel.B1);
        var c1 = TestDataFactory.CreateExam(level: ExamLevel.C1);
        var (sut, ctx) = BuildSut(b1, c1);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, ExamLevel.C1, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().ContainSingle(r => r.Id == c1.Id);
    }

    [Fact(DisplayName = "Browse exams list - Case04 - filters category and level")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "04")]
    [Trait("Level", "Unit")]
    public async Task Should_filter_by_category_and_level()
    {
        var match = TestDataFactory.CreateExam(category: ExamCategory.IELTS, level: ExamLevel.B2);
        var otherCategory = TestDataFactory.CreateExam(category: ExamCategory.TOEIC, level: ExamLevel.B2);
        var otherLevel = TestDataFactory.CreateExam(category: ExamCategory.IELTS, level: ExamLevel.C1);
        var (sut, ctx) = BuildSut(match, otherCategory, otherLevel);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(ExamCategory.IELTS, ExamLevel.B2, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().ContainSingle(r => r.Id == match.Id);
    }

    [Fact(DisplayName = "Browse exams list - Case05 - respects page size")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "05")]
    [Trait("Level", "Unit")]
    public async Task Should_limit_page_size()
    {
        var examA = TestDataFactory.CreateExam();
        var examB = TestDataFactory.CreateExam();
        var examC = TestDataFactory.CreateExam();
        examA.UpdatedAt = DateTime.UtcNow.AddMinutes(-1);
        examB.UpdatedAt = DateTime.UtcNow;
        examC.UpdatedAt = DateTime.UtcNow.AddMinutes(-2);

        var (sut, ctx) = BuildSut(examA, examB, examC);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 2, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().HaveCount(2);
        records.Select(r => r.Id).Should().Contain(new[] { examB.Id, examA.Id });
    }

    [Fact(DisplayName = "Browse exams list - Case06 - supports pagination page 2")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "06")]
    [Trait("Level", "Unit")]
    public async Task Should_return_second_page()
    {
        var first = TestDataFactory.CreateExam();
        var second = TestDataFactory.CreateExam();
        var third = TestDataFactory.CreateExam();
        first.UpdatedAt = DateTime.UtcNow.AddMinutes(-3);
        second.UpdatedAt = DateTime.UtcNow.AddMinutes(-2);
        third.UpdatedAt = DateTime.UtcNow.AddMinutes(-1);

        var (sut, ctx) = BuildSut(first, second, third);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 2, 1, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().ContainSingle();
        records.Single().Id.Should().Be(second.Id);
    }

    [Fact(DisplayName = "Browse exams list - Case07 - invalid page returns bad request")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "07")]
    [Trait("Level", "Unit")]
    public async Task Should_handle_invalid_page()
    {
        var (sut, ctx) = BuildSut(TestDataFactory.CreateExam());
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 0, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().NotBeNull();
    }

    [Fact(DisplayName = "Browse exams list - Case08 - invalid page size returns bad request")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "08")]
    [Trait("Level", "Unit")]
    public async Task Should_handle_invalid_page_size()
    {
        var (sut, ctx) = BuildSut(TestDataFactory.CreateExam());
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 0, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.Should().NotBeNull();
    }

    [Fact(DisplayName = "Browse exams list - Case09 - empty database returns empty list")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "09")]
    [Trait("Level", "Unit")]
    public async Task Should_return_empty_when_no_exam()
    {
        var (sut, ctx) = BuildSut();
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 5, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject;
        records.Should().BeEmpty();
    }

    [Fact(DisplayName = "Browse exams list - Case10 - orders by last update descending")]
    [Trait("Function", "Browse exams list")]
    [Trait("Case", "10")]
    [Trait("Level", "Unit")]
    public async Task Should_order_by_updated_at_desc()
    {
        var older = TestDataFactory.CreateExam();
        var newer = TestDataFactory.CreateExam();
        older.UpdatedAt = DateTime.UtcNow.AddHours(-1);
        newer.UpdatedAt = DateTime.UtcNow;

        var (sut, ctx) = BuildSut(older, newer);
        await using var _ = ctx;

        var result = await sut.ListPublishedAsync(null, null, 1, 10, CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var records = ok.Value.data.Should().BeAssignableTo<IEnumerable<Dto_Public.PublicExamRecord>>()
            .Subject.ToList();
        records.Should().HaveCount(2);
        records.First().Id.Should().Be(newer.Id);
    }
}
