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
    public DbSet<ExamQuestionGroup> ExamQuestionGroups => Set<ExamQuestionGroup>();
    public DbSet<ExamOption> ExamOptions => Set<ExamOption>();
    public DbSet<ReadingPaperJob> ReadingPaperJobs => Set<ReadingPaperJob>();
    public DbSet<ReadingPaperRun> ReadingPaperRuns => Set<ReadingPaperRun>();
    public DbSet<ReadingPaperArtifact> ReadingPaperArtifacts => Set<ReadingPaperArtifact>();
    public DbSet<ReadingPaperArtifactHead> ReadingPaperArtifactHeads => Set<ReadingPaperArtifactHead>();
    public DbSet<ReadingPaperArtifactDependency> ReadingPaperArtifactDependencies => Set<ReadingPaperArtifactDependency>();
    public DbSet<ReadingPaperEvaluation> ReadingPaperEvaluations => Set<ReadingPaperEvaluation>();
    public DbSet<ReadingPaperIssue> ReadingPaperIssues => Set<ReadingPaperIssue>();
    public DbSet<ReadingPaperDecision> ReadingPaperDecisions => Set<ReadingPaperDecision>();
    public DbSet<ReadingPaperOperation> ReadingPaperOperations => Set<ReadingPaperOperation>();
    public DbSet<ReadingPaperLoopCursor> ReadingPaperLoopCursors => Set<ReadingPaperLoopCursor>();
    public DbSet<ReadingPaperEventOutbox> ReadingPaperEventOutbox => Set<ReadingPaperEventOutbox>();
    public DbSet<ReadingPaperBudgetAllocation> ReadingPaperBudgetAllocations => Set<ReadingPaperBudgetAllocation>();
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
            e.Property(x => x.BlankAcceptTexts).HasColumnType("jsonb");
            e.Property(x => x.BlankAcceptRegex).HasColumnType("jsonb");
            e.Property(x => x.MatchPairs).HasColumnType("jsonb");
            e.Property(x => x.OrderCorrects).HasColumnType("text[]");
            e.Property(x => x.ShortAnswerAcceptTexts).HasColumnType("text[]");
            e.Property(x => x.ShortAnswerAcceptRegex).HasColumnType("text[]");
            e.Property(x => x.WordList).HasColumnType("text[]");

            e.HasIndex(x => new { x.SectionId, x.Idx });

            e.HasOne(x => x.Section)
                .WithMany(x => x.Questions)
                .HasForeignKey(x => x.SectionId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();

            e.HasOne(x => x.Group)
                .WithMany(x => x.Questions)
                .HasForeignKey(x => x.GroupId)
                .OnDelete(DeleteBehavior.SetNull)
                .IsRequired(false);
        });
        mb.Entity<ExamQuestionGroup>(e =>
        {
            e.ToTable("exam_question_groups");
            e.HasKey(x => x.Id);
            e.Property(x => x.InstructionMd).IsRequired();
            e.HasIndex(x => new { x.SectionId, x.Idx });

            e.HasOne(x => x.Section)
                .WithMany(x => x.QuestionGroups)
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
        mb.Entity<ReadingPaperJob>(e =>
        {
            e.ToTable("reading_paper_jobs");
            e.HasKey(x => x.Id);
            e.Property(x => x.Topic).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.Property(x => x.SourcesJson).IsRequired();
            e.Property(x => x.SectionsJson).IsRequired();
            e.Property(x => x.Logs).IsRequired().HasDefaultValue("");
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.CancelVersion).HasDefaultValue(0);
            e.Property(x => x.EngineVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SchemaVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.PolicyVersion).HasDefaultValue("2.0.0");
            e.HasIndex(x => new { x.Status, x.LeaseUntil });
            e.HasIndex(x => x.ExamId).IsUnique();
            e.HasIndex(x => new { x.Id, x.Epoch, x.LeaseOwner });
        });

        mb.Entity<ReadingPaperRun>(e =>
        {
            e.ToTable("reading_paper_runs");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.CancelVersion).HasDefaultValue(0);
            e.Property(x => x.EngineVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SchemaVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.PolicyVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SourceRevisionsJson).HasDefaultValue("[]");
            e.Property(x => x.BudgetCapCalls).HasDefaultValue(25);
            e.Property(x => x.BudgetCapTokens).HasDefaultValue(150000);
            e.Property(x => x.BudgetUsedCalls).HasDefaultValue(0);
            e.Property(x => x.BudgetUsedTokens).HasDefaultValue(0);
            e.Property(x => x.BudgetCapWallTimeSeconds).HasDefaultValue(900);
            e.Property(x => x.BudgetUsedWallTimeSeconds).HasDefaultValue(0.0);
            e.HasIndex(x => new { x.JobId, x.RunId }).IsUnique();
            e.HasIndex(x => x.RunId).IsUnique();
            e.HasIndex(x => x.Status);
            e.HasOne(x => x.Job)
                .WithMany(x => x.Runs)
                .HasForeignKey(x => x.JobId)
                .OnDelete(DeleteBehavior.Cascade)
                .IsRequired();
        });

        mb.Entity<ReadingPaperArtifact>(e =>
        {
            e.ToTable("reading_paper_artifacts");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.ArtifactId).IsRequired();
            e.Property(x => x.ArtifactType).IsRequired();
            e.Property(x => x.Version).IsRequired();
            e.Property(x => x.ContentHash).IsRequired();
            e.Property(x => x.PayloadJson).IsRequired();
            e.Property(x => x.ParentRefsJson).IsRequired().HasDefaultValue("[]");
            e.Property(x => x.ProducerVersion).IsRequired().HasDefaultValue("2.0.0");
            e.HasIndex(x => new { x.RunId, x.ArtifactId, x.Version }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.ArtifactId });
            e.HasIndex(x => x.ContentHash);
        });

        mb.Entity<ReadingPaperArtifactHead>(e =>
        {
            e.ToTable("reading_paper_artifact_heads");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.ArtifactId).IsRequired();
            e.Property(x => x.AcceptedVersion).IsRequired();
            e.Property(x => x.AcceptedHash).IsRequired();
            e.HasIndex(x => new { x.RunId, x.ArtifactId }).IsUnique();
        });

        mb.Entity<ReadingPaperArtifactDependency>(e =>
        {
            e.ToTable("reading_paper_artifact_dependencies");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.ArtifactId).IsRequired();
            e.Property(x => x.ParentArtifactId).IsRequired();
            e.HasIndex(x => new { x.RunId, x.ArtifactId, x.Version });
            e.HasIndex(x => new { x.RunId, x.ParentArtifactId, x.ParentVersion });
        });

        mb.Entity<ReadingPaperEvaluation>(e =>
        {
            e.ToTable("reading_paper_evaluations");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.EvaluationId).IsRequired();
            e.Property(x => x.EvaluatorId).IsRequired();
            e.Property(x => x.EvaluatorVersion).HasDefaultValue("1.0.0");
            e.Property(x => x.TargetArtifactId).IsRequired();
            e.Property(x => x.TargetContentHash).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.Property(x => x.PayloadJson).IsRequired();
            e.HasIndex(x => new { x.RunId, x.EvaluationId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.TargetArtifactId, x.TargetVersion });
        });

        mb.Entity<ReadingPaperIssue>(e =>
        {
            e.ToTable("reading_paper_issues");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.IssueId).IsRequired();
            e.Property(x => x.EvaluationId).IsRequired();
            e.Property(x => x.Code).IsRequired();
            e.Property(x => x.Severity).IsRequired();
            e.Property(x => x.Scope).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.HasIndex(x => new { x.RunId, x.IssueId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.EvaluationId });
        });

        mb.Entity<ReadingPaperDecision>(e =>
        {
            e.ToTable("reading_paper_decisions");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.DecisionId).IsRequired();
            e.Property(x => x.Decision).IsRequired();
            e.Property(x => x.CurrentState).IsRequired();
            e.Property(x => x.NextState).IsRequired();
            e.Property(x => x.PayloadJson).IsRequired();
            e.HasIndex(x => new { x.RunId, x.DecisionId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.EvaluationRef });
        });

        mb.Entity<ReadingPaperOperation>(e =>
        {
            e.ToTable("reading_paper_operations");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.OperationId).IsRequired();
            e.Property(x => x.OperationType).IsRequired();
            e.Property(x => x.RequestHash).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.Property(x => x.TokensUsed).HasDefaultValue(0);
            e.Property(x => x.CostReservationUsd).HasColumnType("numeric(12,4)").HasDefaultValue(0m);
            e.Property(x => x.CostUsedUsd).HasColumnType("numeric(12,4)").HasDefaultValue(0m);
            e.Property(x => x.SectionId).IsRequired(false);
            e.Property(x => x.ArtifactId).IsRequired(false);
            e.Property(x => x.ParentOperationId).IsRequired(false);
            e.Property(x => x.WallTimeReservationSeconds).HasDefaultValue(60.0);
            e.Property(x => x.WallTimeUsedSeconds).HasDefaultValue(0.0);
            e.HasIndex(x => new { x.RunId, x.SectionId });
            e.HasIndex(x => new { x.RunId, x.ArtifactId });
            e.HasIndex(x => new { x.RunId, x.ParentOperationId });
            e.HasIndex(x => new { x.RunId, x.OperationId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.RequestHash });
        });
        mb.Entity<ReadingPaperLoopCursor>(e =>
        {
            e.ToTable("reading_paper_loop_cursors");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.ArtifactId).IsRequired();
            e.Property(x => x.StateJson).IsRequired();
            e.HasIndex(x => new { x.RunId, x.ArtifactId }).IsUnique();
        });
        mb.Entity<ReadingPaperEventOutbox>(e =>
        {
            e.ToTable("reading_paper_event_outbox");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.EventId).IsRequired();
            e.Property(x => x.EventType).IsRequired();
            e.Property(x => x.IdempotencyKey).IsRequired();
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.PayloadJson).IsRequired();
            e.Property(x => x.Status).IsRequired();
            e.HasIndex(x => new { x.RunId, x.EventId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.IdempotencyKey }).IsUnique();
            e.HasIndex(x => new { x.Status, x.CreatedAt });
        });

        mb.Entity<ReadingPaperBudgetAllocation>(e =>
        {
            e.ToTable("reading_paper_budget_allocations");
            e.HasKey(x => x.Id);
            e.Property(x => x.RunId).IsRequired();
            e.Property(x => x.ScopeType).IsRequired();
            e.Property(x => x.ScopeId).IsRequired();
            e.Property(x => x.ParentScopeId).IsRequired(false);
            e.Property(x => x.TokenCap).IsRequired();
            e.Property(x => x.CallCap).HasDefaultValue(5);
            e.Property(x => x.WallTimeCapSeconds).HasDefaultValue(300);
            e.HasIndex(x => new { x.RunId, x.ScopeId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.ParentScopeId });
        });
    }
}
