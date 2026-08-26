using ExamService.Domains.Entities;
using Microsoft.EntityFrameworkCore;
using Npgsql.EntityFrameworkCore.PostgreSQL;

namespace ExamService.Infrastructure.Persistence;

public sealed class ExamDbContext(DbContextOptions<ExamDbContext> options) : DbContext(options)
{
    public DbSet<Exam> Exams => Set<Exam>();
    public DbSet<ExamSection> Sections => Set<ExamSection>();
    public DbSet<ExamQuestionGroup> QuestionGroups => Set<ExamQuestionGroup>();
    public DbSet<ExamQuestion> Questions => Set<ExamQuestion>();
    public DbSet<ExamOption> Options => Set<ExamOption>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);

        mb.Entity<Exam>(e =>
        {
            e.ToTable("exams");
            e.HasKey(x => x.Id);
            e.Property(x => x.Slug).IsRequired();
            e.HasIndex(x => x.Slug).IsUnique();
            e.Property(x => x.Title).IsRequired();
            e.Property(x => x.Category).IsRequired();
            e.Property(x => x.Level).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.Property(x => x.DurationMin).IsRequired();
            e.Property(x => x.CreatedAt).HasDefaultValueSql("now()");
        });

        mb.Entity<ExamSection>(e =>
        {
            e.ToTable("exam_sections");
            e.HasKey(x => x.Id);
            e.Property(x => x.Title).IsRequired();
            e.HasIndex(x => new { x.ExamId, x.Idx }).IsUnique();
            e.HasOne(x => x.Exam)
                .WithMany(x => x.Sections)
                .HasForeignKey(x => x.ExamId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });

        mb.Entity<ExamQuestionGroup>(e =>
        {
            e.ToTable("exam_question_groups");
            e.HasKey(x => x.Id);
            e.Property(x => x.InstructionMd).IsRequired();
            e.HasIndex(x => new { x.SectionId, x.Idx }).IsUnique();
            e.HasOne(x => x.Section)
                .WithMany(x => x.QuestionGroups)
                .HasForeignKey(x => x.SectionId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });

        mb.Entity<ExamQuestion>(e =>
        {
            e.ToTable("exam_questions");
            e.HasKey(x => x.Id);
            e.Property(x => x.Skill).IsRequired();
            e.Property(x => x.Payload).HasColumnType("jsonb").IsRequired();
            e.Property(x => x.CorrectAnswer).HasColumnType("jsonb").IsRequired();
            e.Property(x => x.SchemaVersion).HasDefaultValue("1.0.0");
            e.HasIndex(x => new { x.SectionId, x.Idx }).IsUnique();
            e.HasIndex(x => x.Payload)
                .HasMethod("gin")
                .HasOperators("jsonb_path_ops")
                .HasDatabaseName("ix_exam_questions_payload_gin");
            e.HasIndex(x => x.CorrectAnswer)
                .HasMethod("gin")
                .HasOperators("jsonb_path_ops")
                .HasDatabaseName("ix_exam_questions_correct_answer_gin");
            e.HasOne(x => x.Section)
                .WithMany()
                .HasForeignKey(x => x.SectionId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
            e.HasOne(x => x.Group)
                .WithMany()
                .HasForeignKey(x => x.GroupId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);
        });

        mb.Entity<ExamOption>(e =>
        {
            e.ToTable("exam_options");
            e.HasKey(x => x.Id);
            e.Property(x => x.ContentMd).IsRequired();
            e.HasIndex(x => new { x.QuestionId, x.Idx });
            e.HasOne(x => x.Question)
                .WithMany()
                .HasForeignKey(x => x.QuestionId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });
    }
}