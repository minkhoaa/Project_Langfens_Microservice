using Microsoft.EntityFrameworkCore;
using writing_service.Domains.Entities;

namespace writing_service.Infrastructure.Persistence;

public class WritingDbContext(DbContextOptions<WritingDbContext> context) : DbContext(context)
{
    protected override void OnModelCreating(ModelBuilder app)
    {
        base.OnModelCreating(app);
        app.Entity<WritingExam>(option =>
        {
            option.ToTable("writing_exams");
            option.HasKey(o => o.Id);
        });
        app.Entity<WritingSubmission>(option =>
        {
            option.ToTable("writing_submissions");
            option.HasKey(o => o.Id);
            option.HasOne(o => o.WritingExam).WithMany(o => o.WritingSubmissions).HasForeignKey(o => o.ExamId);
        });
        app.Entity<WritingEvaluation>(option =>
        {
            option.ToTable("writing_evaluation");
            option.HasKey(o => o.Id);
            option.HasOne(o => o.WritingSubmission).WithMany(o => o.WritingEvaluations).HasForeignKey(o => o.SubmissionId);
        });
    }

    public DbSet<WritingExam> WritingExams { get; set; }
    public DbSet<WritingSubmission> WritingSubmissions { get; set; }
    public DbSet<WritingEvaluation> WritingEvaluations { get; set; }
}