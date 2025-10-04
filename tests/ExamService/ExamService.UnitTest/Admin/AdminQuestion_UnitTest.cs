// tests/ExamService.UnitTest/AdminQuestion_UnitTest.cs

using exam_service.Contracts.Exams;
using exam_service.Features.Exams.AdminEndpoint.QuestionEndpoint;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts;

namespace ExamService.UnitTest.Admin;

public class AdminQuestionUnitTest
{
    [Fact]
    public async Task AddQuestion_Should_Return_400_When_Section_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminQuestionService(ctx);
            var dto = new DtoAdmin.AdminQuestionUpsert(
                SectionId: 999_999,      // không tồn tại
                Idx: null,
                Type: "Single",
                Skill: "Reading",
                Difficulty: 1,
                PromptMd: "Q1",
                ExplanationMd: "E1"
            );

            var result = await svc.AddAsync(CancellationToken.None, dto);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status400BadRequest, status);
            Assert.False(api!.isSuccess);
            Assert.Contains("Not found section", api.message);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task AddQuestion_Should_Append_And_Return_200()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            // Arrange: 1 Exam, 1 Section, 2 Questions (Idx:1,2)
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec A"));
            var sectionId = secs[0].Id;

            await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 1, prompt: "Q1");
            await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 2, prompt: "Q2");

            var svc = new AdminQuestionService(ctx);
            var dto = new DtoAdmin.AdminQuestionUpsert(
                SectionId: sectionId,
                Idx: null,                // append về cuối
                Type: "Single",
                Skill: "Reading",
                Difficulty: 1,
                PromptMd: "Q3",
                ExplanationMd: "E3"
            );

            // Act
            var result = await svc.AddAsync(CancellationToken.None, dto);

            // Assert
            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);

            var order = await ctx.ExamQuestions
                .Where(x => x.SectionId == sectionId)
                .OrderBy(x => x.Idx)
                .Select(x => x.Idx)
                .ToListAsync();

            Assert.Equal(new[] { 1, 2, 3 }, order);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task AddQuestion_Should_Insert_At_Middle_And_Shift_Succeeding_Items()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx);
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec A"));
            var sectionId = secs[0].Id;

            await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 1, prompt: "Q1");
            await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 2, prompt: "Q2");

            var svc = new AdminQuestionService(ctx);
            var dto = new DtoAdmin.AdminQuestionUpsert(
                SectionId: sectionId,
                Idx: 1,                   // chèn vào giữa => Q1->2, Q2->3
                Type: "Single",
                Skill: "Reading",
                Difficulty: 1,
                PromptMd: "Q-New",
                ExplanationMd: "E-New"
            );

            var result = await svc.AddAsync(CancellationToken.None, dto);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);

            var order = await ctx.ExamQuestions
                .Where(x => x.SectionId == sectionId)
                .OrderBy(x => x.Idx)
                .Select(x => x.PromptMd + ":" + x.Idx)
                .ToListAsync();

            // Kỳ vọng: "Q-New:1", "Q1:2", "Q2:3"
            Assert.Collection(order,
                s => Assert.StartsWith("Q-New:1", s),
                s => Assert.StartsWith("Q1:2", s),
                s => Assert.StartsWith("Q2:3", s));
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
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec A"));
            var sectionId = secs[0].Id;

            var qId = await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 1, prompt: "OldPrompt");

            var dto = new DtoAdmin.AdminQuestionUpdate(
                SectionId: sectionId,
                Idx: 5,
                Type: "Multiple",
                Skill: "Listening",
                Difficulty: 2,
                PromptMd: "NewPrompt",
                ExplanationMd: "NewExp"
            );

            var svc = new AdminQuestionService(ctx);

            var result = await svc.UpdateAsync(CancellationToken.None, dto, qId);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Updated 1", api.message);  
            
            
            ctx.ChangeTracker.Clear();
            var updated = await ctx.ExamQuestions.AsNoTracking().FirstAsync(x => x.Id == qId);
            Assert.Equal(5, updated.Idx);
            Assert.Equal("Multiple", updated.Type);
            Assert.Equal("Listening", updated.Skill);
            Assert.Equal(2, updated.Difficulty);
            Assert.Equal("NewPrompt", updated.PromptMd);
            Assert.Equal("NewExp", updated.ExplanationMd);
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
            var secs = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec A"));
            var sectionId = secs[0].Id;

            var qId = await SeedHelper.SeedQuestionAsync(ctx, sectionId, idx: 1, prompt: "Q1");

            var svc = new AdminQuestionService(ctx);

            var result = await svc.DeleteAsync(CancellationToken.None, qId);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 1", api.message);

            Assert.Equal(0, await ctx.ExamQuestions.CountAsync());
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }

    [Fact]
    public async Task DeleteAsync_Should_Return_Deleted_0_When_Id_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new AdminQuestionService(ctx);

            var result = await svc.DeleteAsync(CancellationToken.None, 123456);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);
            Assert.Contains("Deleted 0", api.message);
        }
        finally { await conn.DisposeAsync(); await ctx.DisposeAsync(); }
    }
}
