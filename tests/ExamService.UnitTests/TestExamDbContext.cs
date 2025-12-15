using exam_service.Domains.Entities;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ExamService.UnitTests;

internal class TestExamDbContext : ExamDbContext
{
    public TestExamDbContext(DbContextOptions<ExamDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);
        mb.Entity<ExamQuestion>().Ignore(x => x.BlankAcceptRegex);
        mb.Entity<ExamQuestion>().Ignore(x => x.BlankAcceptTexts);
        mb.Entity<ExamQuestion>().Ignore(x => x.MatchPairs);
        mb.Entity<ExamQuestion>().Ignore(x => x.OrderCorrects);
        mb.Entity<ExamQuestion>().Ignore(x => x.ShortAnswerAcceptTexts);
        mb.Entity<ExamQuestion>().Ignore(x => x.ShortAnswerAcceptRegex);
    }
}
