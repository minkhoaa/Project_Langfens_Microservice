

using exam_service.Contracts.Exams;
using exam_service.Data.Entities;
using exam_service.Domains.Entities;
using ExamService.UnitTest.Admin;
using Microsoft.AspNetCore.Http;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace ExamService.UnitTest.Public;

public class PublicExamUnitTest
{
    [Fact]
    public async Task ListPublished_Should_Filter_By_Category_Level_And_Paginate_OrderBy_UpdatedAt_Desc()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var e1 = new Exam { Title = "E1", Slug = "e1", Category = ExamCategory.IELTS!, Level = ExamLevel.B1!, Status = ExamStatus.Published, UpdatedAt = DateTime.UtcNow.AddMinutes(-30) };
            var e2 = new Exam { Title = "E2", Slug = "e2", Category = ExamCategory.IELTS!, Level = ExamLevel.B1!, Status = ExamStatus.Published, UpdatedAt = DateTime.UtcNow.AddMinutes(-10) };
            var e3 = new Exam { Title = "E3", Slug = "e3", Category = ExamCategory.IELTS!, Level = ExamLevel.B1!, Status = ExamStatus.Published, UpdatedAt = DateTime.UtcNow.AddMinutes(-20) };
            var e4 = new Exam { Title = "E4", Slug = "e4", Category = ExamCategory.IELTS!, Level = ExamLevel.B1!, Status = ExamStatus.Published, UpdatedAt = DateTime.UtcNow.AddMinutes(-40) };
            
            var draft = new Exam { Title = "D1", Slug = "d1", Category = ExamCategory.IELTS!, Level = ExamLevel.B1!, Status = ExamStatus.Draft, UpdatedAt = DateTime.UtcNow };

            ctx.Exams.AddRange(e1, e2, e3, e4, draft);
            await ctx.SaveChangesAsync();

            var svc = new exam_service.Application.Exam.ExamService(ctx);
            
            var r1 = await svc.ListPublishedAsync(ExamCategory.IELTS, ExamLevel.B1, page: 1, pageSize: 2, CancellationToken.None);
            var (st1, api1) = ResultHelpers.Extract<ApiResultDto>(r1);
            Assert.Equal(StatusCodes.Status200OK, st1);

            var list1 = api1!.data as List<Dto_Public.PublicExamRecord>;
            Assert.NotNull(list1);
            Assert.Equal(2, list1!.Count);
            
            Assert.Equal("e2", list1[0].Slug);
            Assert.Equal("e3", list1[1].Slug);
            
            var r2 = await svc.ListPublishedAsync(ExamCategory.IELTS, ExamLevel.B1, page: 2, pageSize: 2, CancellationToken.None);
            var (_, api2) = ResultHelpers.Extract<ApiResultDto>(r2);
            var list2 = api2!.data as List<Dto_Public.PublicExamRecord>;
            Assert.NotNull(list2);
            Assert.Equal(2, list2!.Count);
            Assert.Equal("e1", list2[0].Slug);
            Assert.Equal("e4", list2[1].Slug);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task ListPublished_Should_Return_Empty_List_When_No_Match_But_Still_200()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            // Seed 1 exam Published nhưng category khác
            ctx.Exams.Add(new Exam {
                Title = "Toeic A", Slug = "toeic-a",
                Category = ExamCategory.TOEIC!, Level = ExamLevel.B1!,
                Status = ExamStatus.Published, UpdatedAt = DateTime.UtcNow
            });
            await ctx.SaveChangesAsync();

            var svc = new exam_service.Application.Exam.ExamService(ctx);

            // Lọc IELTS+B2 => không khớp
            var r = await svc.ListPublishedAsync(ExamCategory.IELTS, ExamLevel.B2, page: 1, pageSize: 10, CancellationToken.None);
            var (st, api) = ResultHelpers.Extract<ApiResultDto>(r);

            // Code trong service luôn Ok nếu .ToListAsync() (không bao giờ null)
            Assert.Equal(StatusCodes.Status200OK, st);

            var list = api!.data as List<Dto_Public.PublicExamRecord>;
            Assert.NotNull(list);
            Assert.Empty(list!);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task GetBySlug_Should_Return_404_When_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new exam_service.Application.Exam.ExamService(ctx);
            var r = await svc.GetBySlugAsync("no-exist-slug", CancellationToken.None);

            var (st, api) = ResultHelpers.Extract<ApiResultDto>(r);
            Assert.Equal(StatusCodes.Status404NotFound, st);
            Assert.False(api!.isSuccess);
            Assert.Contains("Not found", api.message);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task GetBySlug_Should_Return_Exam_Detail_With_Ordered_Sections_Questions_Options()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            // Seed 1 exam có slug cố định
            var exam = new Exam
            {
                Title = "Detail",
                Slug = "detail-slug",
                Category = ExamCategory.IELTS!,
                Level = ExamLevel.B1!,
                Status = ExamStatus.Published,
                UpdatedAt = DateTime.UtcNow
            };
            ctx.Exams.Add(exam);
            await ctx.SaveChangesAsync();

            // Sections cố tình thêm ngược Idx để verify OrderBy(Idx)
            var s2 = new ExamSection { ExamId = exam.Id, Idx = 2, Title = "Sec-2", InstructionsMd = "S2" };
            var s1 = new ExamSection { ExamId = exam.Id, Idx = 1, Title = "Sec-1", InstructionsMd = "S1" };
            ctx.ExamSections.AddRange(s2, s1);
            await ctx.SaveChangesAsync();

            // Question trong S1: Idx 2 rồi 1 (để test order)
            var q2 = new ExamQuestion { SectionId = s1.Id, Idx = 2, Type = "MCQ", Skill = "R", Difficulty = 2, PromptMd = "Q-2" };
            var q1 = new ExamQuestion { SectionId = s1.Id, Idx = 1, Type = "MCQ", Skill = "R", Difficulty = 1, PromptMd = "Q-1" };
            ctx.ExamQuestions.AddRange(q2, q1);
            await ctx.SaveChangesAsync();

            // Options cho Q1: Idx 3,1,2 (để test order)
            ctx.ExamOptions.AddRange(
                new ExamOption { QuestionId = q1.Id, Idx = 3, ContentMd = "O3", IsCorrect = false },
                new ExamOption { QuestionId = q1.Id, Idx = 1, ContentMd = "O1", IsCorrect = true },
                new ExamOption { QuestionId = q1.Id, Idx = 2, ContentMd = "O2", IsCorrect = false }
            );
            await ctx.SaveChangesAsync();

            var svc = new exam_service.Application.Exam.ExamService(ctx);
            var r = await svc.GetBySlugAsync("detail-slug", CancellationToken.None);

            var (st, api) = ResultHelpers.Extract<ApiResultDto>(r);
            Assert.Equal(StatusCodes.Status200OK, st);
            Assert.True(api!.isSuccess);

            var detail = api!.data as Dto_Public.PubLicExamDetailRecord;
            Assert.NotNull(detail);
            Assert.Equal("detail-slug", detail!.Slug);

            // Sections ordered: Idx 1 rồi 2
            Assert.Equal(2, detail.sections.Count);
            Assert.Equal(1, detail.sections[0].idx);
            Assert.Equal("Sec-1", detail.sections[0].Title);
            Assert.Equal(2, detail.sections[1].idx);
            Assert.Equal("Sec-2", detail.sections[1].Title);

            // Questions trong Sec-1 ordered: Q-1 (Idx=1) rồi Q-2 (Idx=2)
            var sec1 = detail.sections[0];
            Assert.Equal(2, sec1.Questions.Count);
            Assert.Equal("Q-1", sec1.Questions[0].PromptMd);
            Assert.Equal("Q-2", sec1.Questions[1].PromptMd);

            // Options của Q-1 ordered: O1 (1), O2 (2), O3 (3)
            var q1Dto = sec1.Questions[0];
            Assert.Equal(new[] { 1, 2, 3 }, q1Dto.Options.Select(o => o.idx).ToArray());
            Assert.Equal(new[] { "O1", "O2", "O3" }, q1Dto.Options.Select(o => o.ContentMd).ToArray());
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }
}