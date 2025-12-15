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

public class ExamDetailTests
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

    [Fact(DisplayName = "View exam detail (by slug/id) - Case01 - returns detail")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "01")]
    [Trait("Level", "Unit")]
    public async Task Should_return_exam_detail()
    {
        var exam = TestDataFactory.CreateExam(slug: "ielts-a1", sectionCount: 1, questionsPerSection: 1, optionsPerQuestion: 2);
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("ielts-a1", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        ok.Value.isSuccess.Should().BeTrue();
        var detail = ok.Value.data.Should().BeAssignableTo<Dto_Public.PubLicExamDetailRecord>().Subject;
        detail.Slug.Should().Be("ielts-a1");
        detail.sections.Should().HaveCount(1);
        detail.sections.First().Questions.Should().HaveCount(1);
        detail.sections.First().Questions.First().Options.Should().HaveCount(2);
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case02 - not found when slug missing")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "02")]
    [Trait("Level", "Unit")]
    public async Task Should_return_not_found_for_unknown_slug()
    {
        var exam = TestDataFactory.CreateExam(slug: "exists");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("missing", CancellationToken.None);

        result.Should().BeOfType<NotFound<ApiResultDto>>();
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case03 - trims and matches slug")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "03")]
    [Trait("Level", "Unit")]
    public async Task Should_fail_when_slug_has_whitespace()
    {
        var exam = TestDataFactory.CreateExam(slug: "trim-slug");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync(" trim-slug ", CancellationToken.None);

        result.Should().BeOfType<NotFound<ApiResultDto>>();
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case04 - orders sections by idx")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "04")]
    [Trait("Level", "Unit")]
    public async Task Should_order_sections_by_index()
    {
        var exam = TestDataFactory.CreateExam(slug: "ordered", sectionCount: 2, questionsPerSection: 0);
        exam.Sections[0].Idx = 2;
        exam.Sections[1].Idx = 1;
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("ordered", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<Dto_Public.PubLicExamDetailRecord>().Subject;
        detail.sections.Should().HaveCount(2);
        detail.sections.First().idx.Should().Be(1);
        detail.sections.Last().idx.Should().Be(2);
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case05 - orders questions by idx")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "05")]
    [Trait("Level", "Unit")]
    public async Task Should_order_questions_by_index()
    {
        var exam = TestDataFactory.CreateExam(slug: "q-order", sectionCount: 1, questionsPerSection: 2, optionsPerQuestion: 0);
        exam.Sections[0].Questions[0].Idx = 3;
        exam.Sections[0].Questions[1].Idx = 1;
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("q-order", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<Dto_Public.PubLicExamDetailRecord>().Subject;
        detail.sections.Single().Questions.Select(q => q.Idx).Should().ContainInOrder(1, 3);
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case06 - orders options by idx")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "06")]
    [Trait("Level", "Unit")]
    public async Task Should_order_options_by_index()
    {
        var exam = TestDataFactory.CreateExam(slug: "opt-order", sectionCount: 1, questionsPerSection: 1, optionsPerQuestion: 2);
        exam.Sections[0].Questions[0].Options[0].Idx = 2;
        exam.Sections[0].Questions[0].Options[1].Idx = 1;
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("opt-order", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<Dto_Public.PubLicExamDetailRecord>().Subject;
        detail.sections.Single().Questions.Single().Options.Select(o => o.idx).Should().ContainInOrder(1, 2);
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case07 - returns metadata")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "07")]
    [Trait("Level", "Unit")]
    public async Task Should_include_metadata_fields()
    {
        var exam = TestDataFactory.CreateExam(slug: "meta", category: ExamCategory.TOEIC, level: ExamLevel.C1);
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("meta", CancellationToken.None);

        var ok = result.Should().BeOfType<Ok<ApiResultDto>>().Subject;
        var detail = ok.Value.data.Should().BeAssignableTo<Dto_Public.PubLicExamDetailRecord>().Subject;
        detail.Category.Should().Be(ExamCategory.TOEIC);
        detail.Level.Should().Be(ExamLevel.C1);
        detail.Title.Should().Be(exam.Title);
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case08 - handles unpublished exams")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "08")]
    [Trait("Level", "Unit")]
    public async Task Should_allow_unpublished_records()
    {
        var exam = TestDataFactory.CreateExam(slug: "draft-detail", status: ExamStatus.Draft);
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("draft-detail", CancellationToken.None);

        result.Should().BeOfType<Ok<ApiResultDto>>();
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case09 - rejects empty slug")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "09")]
    [Trait("Level", "Unit")]
    public async Task Should_not_find_when_slug_empty()
    {
        var exam = TestDataFactory.CreateExam(slug: "slugged");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync(string.Empty, CancellationToken.None);

        result.Should().BeOfType<NotFound<ApiResultDto>>();
    }

    [Fact(DisplayName = "View exam detail (by slug/id) - Case10 - returns null when slug case not matching")]
    [Trait("Function", "View exam detail (by slug/id)")]
    [Trait("Case", "10")]
    [Trait("Level", "Unit")]
    public async Task Should_be_case_sensitive_by_default()
    {
        var exam = TestDataFactory.CreateExam(slug: "lower-slug");
        var (sut, ctx) = BuildSut(exam);
        await using var _ = ctx;

        var result = await sut.GetBySlugAsync("LOWER-SLUG", CancellationToken.None);

        result.Should().BeOfType<NotFound<ApiResultDto>>();
    }
}
