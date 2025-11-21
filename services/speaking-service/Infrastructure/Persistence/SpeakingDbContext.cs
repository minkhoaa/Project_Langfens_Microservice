using Microsoft.EntityFrameworkCore;
using speaking_service.Domains.Entities;

namespace speaking_service.Infrastructure.Persistence;

public class SpeakingDbContext(DbContextOptions<SpeakingDbContext> context) : DbContext(context)
{
    protected override void OnModelCreating(ModelBuilder app)
    {
        base.OnModelCreating(app);

        app.Entity<SpeakingExam>(option =>
        {
            option.ToTable("speaking_exams");
            option.HasKey(o => o.Id);
        });

        app.Entity<SpeakingSubmission>(option =>
        {
            option.ToTable("speaking_submissions");
            option.HasKey(o => o.Id);
            option.HasOne(o => o.SpeakingExam)
                .WithMany(o => o.SpeakingSubmissions)
                .HasForeignKey(o => o.ExamId);
        });

        app.Entity<SpeakingEvaluation>(option =>
        {
            option.ToTable("speaking_evaluations");
            option.HasKey(o => o.Id);
            option.HasOne(o => o.SpeakingSubmission)
                .WithMany(o => o.SpeakingEvaluations)
                .HasForeignKey(o => o.SubmissionId);
        });
    }

    public DbSet<SpeakingExam> SpeakingExams { get; set; } = null!;
    public DbSet<SpeakingSubmission> SpeakingSubmissions { get; set; } = null!;
    public DbSet<SpeakingEvaluation> SpeakingEvaluations { get; set; } = null!;
}
