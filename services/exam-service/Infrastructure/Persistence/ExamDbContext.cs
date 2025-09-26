using exam_service.Data.Entities;
using exam_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Infrastructure.Persistence;

public class ExamDbContext : DbContext
{
    public ExamDbContext(DbContextOptions<ExamDbContext> dbContextOptions) : base(dbContextOptions)
    {
    }

    public DbSet<Exam> Exams => Set<Exam>();
    public DbSet<ExamSection> ExamSections => Set<ExamSection>();
    public DbSet<ExamQuestion> ExamQuestions => Set<ExamQuestion>();
    public DbSet<ExamOption> ExamOptions => Set<ExamOption>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);
        mb.Entity<Exam>(e =>
        {
            e.ToTable("exams");
            e.HasKey(x => x.Id);
            e.Property(x => x.Slug).IsRequired();
            e.HasIndex(x => x.Slug).IsUnique();
            e.Property(x => x.CreatedAt).HasDefaultValueSql("now()");
        });
        mb.Entity<ExamSection>(e =>
        {
            e.ToTable("exam_sections");
            e.HasKey(x => x.Id);

            e.Property(x => x.Title).IsRequired();
            e.HasIndex(x => new { x.ExamId, x.Idx });

            e.HasOne(x => x.Exam)
                .WithMany(x => x.Sections)
                .HasForeignKey(x => x.ExamId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });
        mb.Entity<ExamQuestion>(e =>
        {
            e.ToTable("exam_questions");
            e.HasKey(x => x.Id);

            e.Property(x => x.Type).IsRequired();
            e.Property(x => x.Skill).IsRequired();
            e.Property(x => x.PromptMd).IsRequired();

            e.HasIndex(x => new { x.SectionId, x.Idx });

            e.HasOne(x => x.Section)
                .WithMany(x => x.Questions)
                .HasForeignKey(x => x.SectionId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });
        mb.Entity<ExamOption>(e =>
        {
            e.ToTable("exam_options");
            e.HasKey(x => x.Id);
            e.Property(x => x.ContentMd).IsRequired();
            e.HasIndex(x => new { x.QuestionId, x.Idx });
            e.HasOne(x => x.Question).WithMany(x => x.Options).HasForeignKey(x => x.QuestionId)
                .OnDelete(DeleteBehavior.Cascade).IsRequired();
        });
    }
}