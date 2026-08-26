using attempt_service.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Infrastructure.Persistence;

public class AttemptDbContext : DbContext
{
    public AttemptDbContext(DbContextOptions<AttemptDbContext> options) : base(options) { }

    public DbSet<Attempt> Attempts { get; set; } = null!;
    public DbSet<AttemptAnswer> AttemptAnswers { get; set; } = null!;
    public DbSet<PlacementResult> PlacementResults { get; set; } = null!;
    public DbSet<StudyGoal> StudyGoals { get; set; } = null!;
    public DbSet<Note> Notes { get; set; } = null!;
    public DbSet<QuestionBookmark> QuestionBookmarks { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);

        mb.Entity<Attempt>(e =>
        {
            e.ToTable("attempts");
            e.HasKey(x => x.Id);
            e.Property(x => x.PaperJson).HasColumnType("jsonb").IsRequired();
            e.Property(x => x.RawScore).HasColumnType("numeric(6,2)");
            e.Property(x => x.ScaledScore).HasColumnType("numeric(4,1)");
            e.HasIndex(x => x.UserId).HasDatabaseName("ix_attempts_user_id");
            e.HasIndex(x => new { x.UserId, x.ExamId }).HasDatabaseName("ix_attempts_user_exam");
        });

        mb.Entity<AttemptAnswer>(e =>
        {
            e.ToTable("attempt_answers");
            e.HasKey(x => x.Id);
            e.Property(x => x.AnswerJson).HasColumnType("jsonb").IsRequired();
            e.Property(x => x.RagFeedbackJson).HasColumnType("jsonb");
            e.Property(x => x.AwardedPoints).HasColumnType("numeric(5,2)");
            e.HasIndex(x => new { x.AttemptId, x.QuestionId }).IsUnique();
            e.HasIndex(x => x.AttemptId).HasDatabaseName("ix_attempt_answers_attempt_id");
            e.HasOne(x => x.Attempt)
                .WithMany(x => x.Answers)
                .HasForeignKey(x => x.AttemptId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });

        mb.Entity<PlacementResult>(e =>
        {
            e.ToTable("placement_results");
            e.HasKey(x => x.Id);
            e.Property(x => x.WritingGradeJson).HasColumnType("jsonb");
            e.Property(x => x.SpeakingGradeJson).HasColumnType("jsonb");
            e.HasIndex(x => x.UserId).HasDatabaseName("ix_placement_results_user_id");
            e.HasIndex(x => x.AttemptId).HasDatabaseName("ix_placement_results_attempt_id");
            e.HasOne(x => x.Attempt)
                .WithMany(x => x.PlacementResults)
                .HasForeignKey(x => x.AttemptId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });

        mb.Entity<StudyGoal>(e =>
        {
            e.ToTable("study_goals");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId).HasDatabaseName("ix_study_goals_user_id");
        });

        mb.Entity<Note>(e =>
        {
            e.ToTable("notes");
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.UserId).HasDatabaseName("ix_notes_user_id");
        });

        mb.Entity<QuestionBookmark>(e =>
        {
            e.ToTable("question_bookmarks");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.UserId, x.QuestionId });
        });
    }
}