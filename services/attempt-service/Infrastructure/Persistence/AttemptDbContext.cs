using System.Net;
using attempt_service.Domain.Entities;
using attempt_service.Domains.Entities;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.EntityFrameworkCore;

namespace attempt_service.Infrastructure.Persistence;

public class AttemptDbContext : DbContext
{
    public AttemptDbContext(DbContextOptions<AttemptDbContext> options) : base(options)
    {
    }

    public DbSet<Attempt> Attempts { get; set; }
    public DbSet<AttemptAnswer> AttemptAnswers { get; set; }
    public DbSet<PlacementResult> PlacementResults { get; set; }
    public DbSet<StudyGoal> StudyGoals { get; set; }
    public DbSet<QuestionBookmark> QuestionBookmarks { get; set; }
    public DbSet<Note> Notes { get; set; }



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

            aa.HasIndex(x => new { x.AttemptId, x.QuestionId })
                .IsUnique()
                .HasDatabaseName("uq_attempt_answer_attempt_question");
        });
        app.Entity<PlacementResult>(a =>
        {
            a.ToTable("placement_result");
            a.HasOne(k => k.Attempt)
            .WithMany(k => k.PlacementResults)
            .HasForeignKey(p => p.AttemptId);
            a.HasIndex(k => new { k.UserId, k.CreatedAt });
            a.HasIndex(k => k.ExamId);
            a.HasIndex(k => k.AttemptId).IsUnique();
        });

        app.Entity<StudyGoal>(sg =>
        {
            sg.ToTable("study_goals");
            sg.Property(x => x.TargetBandScore).HasPrecision(3, 1);
            sg.Property(x => x.StudyHoursPerDay).HasPrecision(3, 1);
            sg.Property(x => x.FocusSkills).HasColumnType("text[]");
            sg.HasIndex(x => x.UserId).HasDatabaseName("idx_study_goal_user");
        });

        app.Entity<QuestionBookmark>(qb =>
        {
            qb.ToTable("question_bookmarks");
            qb.HasIndex(x => new { x.UserId, x.QuestionId })
                .IsUnique()
                .HasDatabaseName("uq_bookmark_user_question");
            qb.HasIndex(x => x.UserId).HasDatabaseName("idx_bookmark_user");
            qb.HasIndex(x => x.CreatedAt).HasDatabaseName("idx_bookmark_created");
        });

        app.Entity<Note>(n =>
        {
            n.ToTable("notes");
            n.HasIndex(x => x.UserId).HasDatabaseName("idx_note_user");
            n.HasIndex(x => new { x.UserId, x.AttemptId }).HasDatabaseName("idx_note_user_attempt");
            n.HasIndex(x => x.CreatedAt).HasDatabaseName("idx_note_created");
        });
    }
}

