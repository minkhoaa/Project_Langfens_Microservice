using attempt_service.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Infrastructure.Persistence;

public class AttemptDbContext : DbContext
{
    public AttemptDbContext(DbContextOptions<AttemptDbContext> options) : base(options)
    {
    }

    public DbSet<Attempt> Attempts { get; set; }
    public DbSet<AttemptAnswer> AttemptAnswers { get; set; }

    protected override void OnModelCreating(ModelBuilder app)
    {
        base.OnModelCreating(app);

        app.Entity<Attempt>(a =>
        {
            a.ToTable("attempts");
            a.Property(x => x.Status)
                .HasColumnName("status")
                .HasMaxLength(16)
                .IsRequired();
            a.Property(x => x.Status).HasMaxLength(16);
            a.Property(x => x.PaperJson).HasColumnType("jsonb");

            a.Property(x => x.RawScore).HasPrecision(6, 2);
            a.Property(x => x.ScaledScore).HasPrecision(6, 2);

            // Indexes
            a.HasIndex(x => new { x.UserId, x.Status }).HasDatabaseName("idx_attempt_user_status");
            a.HasIndex(x => new { x.ExamId, x.Status }).HasDatabaseName("idx_attempt_exam_status");
        });

        app.Entity<AttemptAnswer>(aa =>
        {
            aa.ToTable("attempt_answer");
            aa.HasOne(x => x.Attempt)
                .WithMany(x => x.Answers)
                .HasForeignKey(x => x.AttemptId)
                .OnDelete(DeleteBehavior.Cascade);

            aa.Property(x => x.SelectedOptionIds).HasColumnType("uuid[]");
            aa.Property(x => x.AwardedPoints).HasPrecision(6, 2);

            // Đảm bảo 1 câu hỏi chỉ có 1 dòng answer/attempt (UPSERT autosave dễ)
            aa.HasIndex(x => new { x.AttemptId, x.QuestionId })
                .IsUnique()
                .HasDatabaseName("uq_attempt_answer_attempt_question");
        });
    }
}
