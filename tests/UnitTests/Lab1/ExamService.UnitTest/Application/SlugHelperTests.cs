using exam_service.Application.Common;
using exam_service.Infrastructure.Persistence;
using FluentAssertions;

namespace ExamService.UnitTest.Application;

public class SlugHelperTests
{
    [Fact]
    public void ToSlug_Should_Remove_Diacritics_And_SpecialCharacters()
    {
        var slug = SlugHelper.ToSlug("  Bài Thi Đọc 1!  ");
        slug.Should().Be("bai-thi-doc-1");
    }

    [Fact]
    public void ToSlug_Should_Fallback_When_Input_Invalid()
    {
        var slug = SlugHelper.ToSlug("    ");
        slug.Should().StartWith("exam-");
    }

    [Fact]
    public async Task MakeUniqueSlugAsync_Should_Add_Suffix_When_Duplicate()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        await using var _ = conn;
        await using var __ = ctx;

        ctx.Exams.Add(new exam_service.Domains.Entities.Exam
        {
            Title = "IELTS Reading",
            Slug = "ielts-reading",
            Category = Shared.ExamDto.Contracts.Exam.Enums.ExamCategory.IELTS!,
            Level = Shared.ExamDto.Contracts.Exam.Enums.ExamLevel.B1!,
            Status = Shared.ExamDto.Contracts.Exam.Enums.ExamStatus.Draft,
            DurationMin = 60,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        });
        await ctx.SaveChangesAsync();

        var unique = await SlugHelper.MakeUniqueSlugAsync(ctx, "ielts-reading", CancellationToken.None);
        unique.Should().Be("ielts-reading-2");
    }
}
