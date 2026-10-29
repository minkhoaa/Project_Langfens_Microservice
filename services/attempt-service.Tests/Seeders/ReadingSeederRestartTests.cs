using attempt_service.Tests.Helpers;
using exam_service.Data;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace attempt_service.Tests.Seeders;

public class ReadingSeederRestartTests
{
    [Fact]
    public async Task Restart_preserves_existing_paper_ids_author_edits_and_grading_keys()
    {
        var options = OfflineExamDbContext.Options(Guid.NewGuid().ToString());
        Guid optionId;
        string before;
        await using (var db = new OfflineExamDbContext(options))
        {
            await ReadingSeeder.SeedReadingExamAsync(db);
            Assert.Equal(1, await db.Exams.CountAsync());
            Assert.Equal(5, await db.ExamSections.CountAsync());
            Assert.Equal(25, await db.ExamQuestions.CountAsync());
            var exam = await db.Exams.SingleAsync();
            exam.Title = "Author-edited title";
            exam.Status = "Draft";
            var option = await db.ExamOptions.FirstAsync();
            optionId = option.Id;
            option.ContentMd = "Author-edited option";
            option.IsCorrect = !option.IsCorrect;
            var question = await db.ExamQuestions.FirstAsync(q => q.BlankAcceptTexts != null);
            question.ExplanationMd = "Author explanation";
            question.ModelAnswers = ["Author model"];
            question.BlankAcceptTexts = new() { ["1"] = ["Author grading key"] };
            await db.SaveChangesAsync();
            before = await Snapshot(db);
        }
        await using (var restarted = new OfflineExamDbContext(options))
        {
            await ReadingSeeder.SeedReadingExamAsync(restarted);
            Assert.Equal(before, await Snapshot(restarted));
            Assert.Equal("Author-edited option", (await restarted.ExamOptions.SingleAsync(o => o.Id == optionId)).ContentMd);
        }
    }

    [Fact]
    public async Task Fresh_databases_produce_identical_question_and_option_ids_and_keys()
    {
        await using var first = new OfflineExamDbContext(OfflineExamDbContext.Options(Guid.NewGuid().ToString()));
        await using var second = new OfflineExamDbContext(OfflineExamDbContext.Options(Guid.NewGuid().ToString()));
        await ReadingSeeder.SeedReadingExamAsync(first);
        await ReadingSeeder.SeedReadingExamAsync(second);
        Assert.Equal(await Snapshot(first), await Snapshot(second));
        var options = await first.ExamOptions.Select(o => o.Id).ToListAsync();
        Assert.NotEmpty(options);
        Assert.Equal(options.Count, options.Distinct().Count());
        Assert.DoesNotContain(Guid.Empty, options);
    }

    [Fact]
    public async Task Existing_slug_with_different_id_is_not_replaced_or_repaired()
    {
        await using var db = new OfflineExamDbContext(OfflineExamDbContext.Options(Guid.NewGuid().ToString()));
        var exam = ExamServiceTestHost.Paper();
        exam.Slug = "ielts-reading-standard-test";
        db.Exams.Add(exam);
        await db.SaveChangesAsync();
        var before = await Snapshot(db);
        await ReadingSeeder.SeedReadingExamAsync(db);
        Assert.Equal(before, await Snapshot(db));
        Assert.Equal(exam.Id, (await db.Exams.SingleAsync()).Id);
    }

    private static async Task<string> Snapshot(OfflineExamDbContext db)
    {
        var exams = await db.Exams.AsNoTracking().OrderBy(e => e.Id)
            .Select(e => new { e.Id, e.Slug, e.Title, e.Status }).ToListAsync();
        var sections = await db.ExamSections.AsNoTracking().OrderBy(s => s.Id)
            .Select(s => new { s.Id, s.ExamId, s.Idx, s.PassageMd }).ToListAsync();
        var questions = await db.ExamQuestions.AsNoTracking().OrderBy(q => q.Id)
            .Select(q => new { q.Id, q.SectionId, q.Idx, q.Type, q.PromptMd, q.ExplanationMd, q.ModelAnswers, q.BlankAcceptTexts,
                q.BlankAcceptRegex, q.MatchPairs, q.OrderCorrects, q.ShortAnswerAcceptTexts, q.ShortAnswerAcceptRegex }).ToListAsync();
        var options = await db.ExamOptions.AsNoTracking().OrderBy(o => o.Id)
            .Select(o => new { o.Id, o.QuestionId, o.Idx, o.ContentMd, o.IsCorrect }).ToListAsync();
        return System.Text.Json.JsonSerializer.Serialize(new { exams, sections, questions, options });
    }
}
