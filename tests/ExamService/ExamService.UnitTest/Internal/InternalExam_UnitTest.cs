using exam_service.Contracts.Exams;
using exam_service.Domains.Entities;
using exam_service.Features.Exams.InternalEndpoint;
using ExamService.UnitTest.Admin;
using Microsoft.AspNetCore.Http;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Exam.Enums;

namespace ExamService.UnitTest.Internal;

public class InternalExam_UnitTest
{
    [Fact]
    public async Task GetByExamId_Should_Return_404_When_NotFound()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var svc = new InternalExamService(ctx);

            var result = await svc.GetByExamIdAsync(999999, CancellationToken.None, showAnswer: false);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status404NotFound, status);
            Assert.False(api!.isSuccess);
            Assert.Contains("Not found", api.message);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task GetByExamId_Should_Return_Paper_Without_Answers_When_ShowAnswer_False()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            // Seed: Exam -> Section(1) -> Question(2) -> Options(3 for q1, 2 for q2)
            var examId = await SeedHelper.SeedExamAsync(ctx, "Internal Exam");
            var sections = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec A"));
            var secId = sections[0].Id;

            var q1 = new ExamQuestion
            {
                SectionId = secId, Idx = 1,
                Type = QuestionType.DiagramLabel, Skill = QuestionSkill.Listening,
                Difficulty = 1, PromptMd = "Q1?", ExplanationMd = "Exp1"
            };
            var q2 = new ExamQuestion
            {
                SectionId = secId, Idx = 2,
                Type = QuestionType.DiagramLabel, Skill = QuestionSkill.Listening,
                Difficulty = 2, PromptMd = "Q2?", ExplanationMd = "Exp2"
            };
            ctx.ExamQuestions.AddRange(q1, q2);
            await ctx.SaveChangesAsync();

            ctx.ExamOptions.AddRange(
                new ExamOption { QuestionId = q1.Id, Idx = 1, IsCorrect = false, ContentMd = "A1" },
                new ExamOption { QuestionId = q1.Id, Idx = 2, IsCorrect = true, ContentMd = "A2" },
                new ExamOption { QuestionId = q1.Id, Idx = 3, IsCorrect = false, ContentMd = "A3" },
                new ExamOption { QuestionId = q2.Id, Idx = 1, IsCorrect = false, ContentMd = "B1" },
                new ExamOption { QuestionId = q2.Id, Idx = 2, IsCorrect = true, ContentMd = "B2" }
            );
            await ctx.SaveChangesAsync();

            var svc = new InternalExamService(ctx);
            var result = await svc.GetByExamIdAsync(examId, CancellationToken.None, showAnswer: false);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);

            var paper = api.data as InternalExamDto.InternalDeliveryExam;
            Assert.NotNull(paper);
            Assert.Equal(examId, paper!.Id);
            Assert.Single(paper.Sections);

            var sec = paper.Sections[0];
            Assert.Equal("Sec A", sec.Title);

            // Không lộ đáp án
            Assert.All(sec.Questions.SelectMany(q => q.Options),
                opt => Assert.Null(opt.IsCorrect));

            // Kiểm tra số lượng
            Assert.Equal(2, sec.Questions.Count);
            var q1Dto = sec.Questions.First(x => x.PromptMd == "Q1?");
            var q2Dto = sec.Questions.First(x => x.PromptMd == "Q2?");
            Assert.Equal(3, q1Dto.Options.Count);
            Assert.Equal(2, q2Dto.Options.Count);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }

    [Fact]
    public async Task GetByExamId_Should_Return_Paper_With_Answers_When_ShowAnswer_True()
    {
        var (ctx, conn) = SqlTestHelper.CreateInMemory();
        try
        {
            var examId = await SeedHelper.SeedExamAsync(ctx, "Internal Exam 2");
            var sections = await SeedHelper.SeedSectionsAsync(ctx, examId, (1, "Sec B"));
            var secId = sections[0].Id;

            var q = new ExamQuestion
            {
                SectionId = secId, Idx = 1,
                Type = "MCQ", Skill = "Listening",
                Difficulty = 3, PromptMd = "Q?", ExplanationMd = "Exp"
            };
            ctx.ExamQuestions.Add(q);
            await ctx.SaveChangesAsync();

            ctx.ExamOptions.AddRange(
                new ExamOption { QuestionId = q.Id, Idx = 1, IsCorrect = false, ContentMd = "O1" },
                new ExamOption { QuestionId = q.Id, Idx = 2, IsCorrect = true, ContentMd = "O2" }
            );
            await ctx.SaveChangesAsync();

            var svc = new InternalExamService(ctx);
            var result = await svc.GetByExamIdAsync(examId, CancellationToken.None, showAnswer: true);

            var (status, api) = ResultHelpers.Extract<ApiResultDto>(result);
            Assert.Equal(StatusCodes.Status200OK, status);
            Assert.True(api!.isSuccess);

            var paper = api.data as InternalExamDto.InternalDeliveryExam;
            Assert.NotNull(paper);
            Assert.Single(paper!.Sections);

            var qDto = paper.Sections[0].Questions.Single();
            Assert.Equal("Q?", qDto.PromptMd);

            // Lộ đáp án
            var opts = qDto.Options.OrderBy(x => x.Idx).ToList();
            Assert.Equal(2, opts.Count);
            Assert.False(opts[0].IsCorrect!.Value);
            Assert.True(opts[1].IsCorrect!.Value);
        }
        finally
        {
            await conn.DisposeAsync();
            await ctx.DisposeAsync();
        }
    }
}