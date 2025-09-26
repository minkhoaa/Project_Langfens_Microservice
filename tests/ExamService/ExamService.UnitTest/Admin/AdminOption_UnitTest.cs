using exam_service.Contracts.Exams;
using exam_service.Data.Entities;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.AdminEndpoint.OptionEndpoint;
using exam_service.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.Contracts.Contracts;

namespace ExamService.UnitTest.Admin;

public class AdminOptionUnitTest
{

    // ===== Local seed helpers cho Option tests =====
    private static async Task<int> SeedQuestionAsync(ExamDbContext ctx, int examId)
    {
        // Tạo 1 Section
        var sec = new ExamSection
        {
            ExamId = examId,
            Idx = 1,
            Title = "Sec 1",
            InstructionsMd = ""
        };
        ctx.ExamSections.Add(sec);
        await ctx.SaveChangesAsync();

        // Tạo 1 Question (đủ field not-null)
        var q = new ExamQuestion
        {
            SectionId = sec.Id,
            Idx = 1,
            PromptMd = "Q1",
            Type = "single",       // string cho nhẹ, tránh lệ thuộc enum
            Skill = "reading",
            Difficulty = 1,
            ExplanationMd = null
        };
        ctx.ExamQuestions.Add(q);
        await ctx.SaveChangesAsync();

        return q.Id;
    }

    private static async Task<List<ExamOption>> SeedOptionsAsync(
        ExamDbContext ctx, int questionId,
        params (int idx, string content, bool isCorrect)[] opts)
    {
        var list = new List<ExamOption>();
        foreach (var (idx, content, isCorrect) in opts)
        {
            var op = new ExamOption
            {
                QuestionId = questionId,
                Idx = idx,
                ContentMd = content,
                IsCorrect = isCorrect
            };
            list.Add(op);
            ctx.ExamOptions.Add(op);
        }
        await ctx.SaveChangesAsync();
        return list;
    }

    // ===================== TESTS =====================

    [Fact]
    public async Task AddOption_Should_Return_404_When_Question_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminOptionService(ctx);
            var dto = new DtoAdmin.AdminOptionUpsert(
                QuestionId: 999_999, // không tồn tại
                Idx: null,
                ContentMd: "A",
                IsCorrect: false
            );

            var result = await svc.AddAsync(dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status404NotFound, status);
            Assert.False(api!.isSuccess);
            Assert.Contains("Question not found", api.message);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task AddOption_Should_Insert_At_End_And_Return_200()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var qId    = await SeedQuestionAsync(ctx, examId);

            // đã có 2 option idx 1,2
            await SeedOptionsAsync(ctx, qId, (1, "A", false), (2, "B", true));

            var svc = new AdminOptionService(ctx);
            var dto = new DtoAdmin.AdminOptionUpsert(
                QuestionId: qId,
                Idx: null, // append cuối
                ContentMd: "C",
                IsCorrect: false
            );

            var result = await svc.AddAsync(dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api is not null, "api is null");
            Assert.True(api!.isSuccess, $"isSuccess=false; message={api.message}");
            Assert.Contains("Added option successfully", api.message);

            var order = await ctx.ExamOptions.Where(x => x.QuestionId == qId)
                .OrderBy(x => x.Idx).Select(x => x.Idx).ToListAsync();
            Assert.Equal(new[] { 1, 2, 3 }, order);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task AddOption_Should_Insert_In_Middle_And_Shift_Following()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var qId    = await SeedQuestionAsync(ctx, examId);

            await SeedOptionsAsync(ctx, qId, (1, "A", false), (2, "B", true), (3, "C", false));

            var svc = new AdminOptionService(ctx);
            var dto = new DtoAdmin.AdminOptionUpsert(
                QuestionId: qId,
                Idx: 2, // chèn vào vị trí 2 -> B,C dịch xuống
                ContentMd: "X",
                IsCorrect: false
            );

            var result = await svc.AddAsync(dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);

            var contentsByIdx = await ctx.ExamOptions.Where(x => x.QuestionId == qId)
                .OrderBy(x => x.Idx)
                .Select(x => x.ContentMd)
                .ToListAsync();

            Assert.Equal(new[] { "A", "X", "B", "C" }, contentsByIdx);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task UpdateAsync_Should_Update_One_Row()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var qId    = await SeedQuestionAsync(ctx, examId);

            var options = await SeedOptionsAsync(ctx, qId, (1, "A", false));
            var id = options[0].Id;

            var svc = new AdminOptionService(ctx);
            var dto = new DtoAdmin.AdminOptionUpdate(
                QuestionId: qId,
                Idx: 5,
                ContentMd: "A-Updated",
                IsCorrect: true
            );

            var result = await svc.UpdateAsync(id, dto, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Updated 1", api.message);
            ctx.ChangeTracker.Clear();

            var updated = await ctx.ExamOptions.FindAsync(id);
            Assert.Equal(5, updated!.Idx);
            Assert.Equal("A-Updated", updated.ContentMd);
            Assert.True(updated.IsCorrect);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task DeleteAsync_Should_Delete_One_Row()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var qId    = await SeedQuestionAsync(ctx, examId);

            var options = await SeedOptionsAsync(ctx, qId, (1, "A", false));
            var id = options[0].Id;

            var svc = new AdminOptionService(ctx);
            var result = await svc.DeleteAsync(id, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 1", api.message);

            Assert.Equal(0, await ctx.ExamOptions.CountAsync());
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task DeleteAsync_Should_Return_Deleted_0_When_Id_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminOptionService(ctx);
            var result = await svc.DeleteAsync(123456, CancellationToken.None);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 0", api.message);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }
}