// tests/ExamService.UnitTest/SeedHelper.cs
using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using exam_service.Data.Entities;
using Shared.ExamDto.Contracts.Exam.Enums; // ExamQuestion, ExamOption

namespace ExamService.UnitTest;

internal class SeedHelper
{
    public static async Task<int> SeedExamAsync(ExamDbContext ctx, string title = "Exam A")
    {
        string Slugify(string s) => s.ToLower().Replace(' ', '-');

        var exam = new Exam
        {
            Title       = title,
            Slug        = $"{Slugify(title)}-{Guid.NewGuid():N}", // LUÔN unique
            Category    = ExamCategory.IELTS!,
            Level       = ExamLevel.B1!,
            Status      = ExamStatus.Draft,
            DurationMin = 60,
            CreatedAt   = DateTime.UtcNow,
            UpdatedAt   = DateTime.UtcNow
        };

        ctx.Exams.Add(exam);
        await ctx.SaveChangesAsync();
        return exam.Id;
    }

    public static async Task<List<ExamSection>> SeedSectionsAsync(
        ExamDbContext ctx, int examId, params (int idx, string title)[] items)
    {
        var list = new List<ExamSection>();
        foreach (var (idx, title) in items)
        {
            var sec = new ExamSection
            {
                ExamId        = examId,
                Idx           = idx,
                Title         = title,
                InstructionsMd= ""
            };
            list.Add(sec);
            ctx.ExamSections.Add(sec);
        }

        await ctx.SaveChangesAsync();
        return list;
    }

    // ---- Thêm mới cho test Option/Question ----

    public static async Task<int> SeedQuestionAsync(
        ExamDbContext ctx,
        int sectionId,
        int idx = 1,
        string? prompt = null,
        string type = "Single",
        string skill = "Reading",
        int difficulty = 1)
    {
        var q = new ExamQuestion
        {
            SectionId     = sectionId,
            Idx           = idx,
            Type          = type,
            Skill         = skill,
            Difficulty    = difficulty,
            PromptMd      = prompt ?? $"Q{idx}",
            ExplanationMd = ""
        };
        ctx.ExamQuestions.Add(q);
        await ctx.SaveChangesAsync();
        return q.Id;
    }

    public static async Task<List<ExamOption>> SeedOptionsAsync(
        ExamDbContext ctx,
        int questionId,
        params (int idx, string content, bool isCorrect)[] items)
    {
        var list = new List<ExamOption>();
        foreach (var (idx, content, isCorrect) in items)
        {
            var opt = new ExamOption
            {
                QuestionId = questionId,
                Idx        = idx,
                ContentMd  = content,
                IsCorrect  = isCorrect
            };
            list.Add(opt);
            ctx.ExamOptions.Add(opt);
        }
        await ctx.SaveChangesAsync();
        return list;
    }
}
