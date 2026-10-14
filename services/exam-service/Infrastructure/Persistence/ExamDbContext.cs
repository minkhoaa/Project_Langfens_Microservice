using exam_service.Domains.Entities;
using Microsoft.EntityFrameworkCore;

namespace exam_service.Infrastructure.Persistence;

public class ExamDbContext : DbContext
{
    public ExamDbContext(DbContextOptions<ExamDbContext> dbContextOptions) : base(dbContextOptions)
    {
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        base.OnConfiguring(optionsBuilder);
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
        }
    }

    public DbSet<Exam> Exams => Set<Exam>();
    public DbSet<ExamSection> ExamSections => Set<ExamSection>();
    public DbSet<ExamQuestion> ExamQuestions => Set<ExamQuestion>();
    public DbSet<ExamQuestionGroup> ExamQuestionGroups => Set<ExamQuestionGroup>();
    public DbSet<ExamOption> ExamOptions => Set<ExamOption>();

    public DbSet<ReadingPaperJob> ReadingPaperJobs => Set<ReadingPaperJob>();
    public DbSet<ReadingPaperBenchmarkCampaign> ReadingPaperBenchmarkCampaigns => Set<ReadingPaperBenchmarkCampaign>();

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
    public DbSet<ReadingPaperEventOutbox> ReadingPaperEventOutboxes => ReadingPaperEventOutbox;
    public DbSet<ReadingPaperBudgetAllocation> ReadingPaperBudgetAllocations => Set<ReadingPaperBudgetAllocation>();

    public DbSet<ReadingPaperEntityLineage> ReadingPaperEntityLineages => Set<ReadingPaperEntityLineage>();
    public DbSet<ReadingPaperHumanFeedback> ReadingPaperHumanFeedbacks => Set<ReadingPaperHumanFeedback>();
    public DbSet<ReadingPaperFeedbackCurationRecord> ReadingPaperFeedbackCurationRecords => Set<ReadingPaperFeedbackCurationRecord>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);
        mb.UseIdentityByDefaultColumns();

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
            e.Property(x => x.ModelAnswers).HasColumnType("jsonb");
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
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.CancelVersion).HasDefaultValue(0);
            e.Property(x => x.EngineVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SchemaVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.PolicyVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.Logs).HasDefaultValue("");
            e.HasIndex(x => x.ExamId).IsUnique();
            e.HasIndex(x => new { x.Status, x.LeaseUntil });
            e.HasIndex(x => new { x.Id, x.Epoch, x.LeaseOwner });
        });

        mb.Entity<ReadingPaperBenchmarkCampaign>(e =>
        {
            e.ToTable("reading_paper_benchmark_campaigns");
            e.HasKey(x => x.CampaignId);
            e.Property(x => x.CampaignId).HasMaxLength(128);
            e.Property(x => x.AuthorizationId).HasMaxLength(128);
            e.Property(x => x.AuthorizedBy).HasMaxLength(200);
            e.Property(x => x.ConfigSha256).HasMaxLength(64);
            e.Property(x => x.CorpusSha256).HasMaxLength(64);
            e.Property(x => x.Status).HasMaxLength(24);
            e.HasIndex(x => x.Status);
        });

        mb.Entity<ReadingPaperRun>(e =>
        {
            e.ToTable("reading_paper_runs");
            e.HasKey(x => x.Id);
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.CancelVersion).HasDefaultValue(0);
            e.Property(x => x.EngineVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SchemaVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.PolicyVersion).HasDefaultValue("2.0.0");
            e.Property(x => x.SourceRevisionsJson).HasDefaultValue("[]");
            e.Property(x => x.BudgetCapCalls).HasDefaultValue(25);
            e.Property(x => x.BudgetCapTokens).HasDefaultValue(150000);
            e.Property(x => x.BudgetCapWallTimeSeconds).HasDefaultValue(900);
            e.Property(x => x.BudgetUsedCalls).HasDefaultValue(0);
            e.Property(x => x.BudgetUsedTokens).HasDefaultValue(0);
            e.Property(x => x.BudgetUsedWallTimeSeconds).HasDefaultValue(0.0);
            e.Property(x => x.BudgetProfileVersion).HasMaxLength(64);
            e.Property(x => x.BudgetProfileSha256).HasMaxLength(64);
            e.Property(x => x.BudgetProfileSource).HasMaxLength(256);
            e.HasIndex(x => x.RunId).IsUnique();
            e.HasIndex(x => x.Status);
            e.HasIndex(x => new { x.BenchmarkCampaignId, x.BenchmarkCaseId })
                .IsUnique()
                .HasFilter("\"BenchmarkCampaignId\" IS NOT NULL");
            e.HasIndex(x => new { x.JobId, x.RunId }).IsUnique();
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
            e.Property(x => x.ParentRefsJson).HasDefaultValue("[]");
            e.Property(x => x.ProducerVersion).HasDefaultValue("2.0.0");
            e.HasIndex(x => x.ContentHash);
            e.HasIndex(x => new { x.RunId, x.ArtifactId });
            e.HasIndex(x => new { x.RunId, x.ArtifactId, x.Version }).IsUnique();
        });

        mb.Entity<ReadingPaperArtifactHead>(e =>
        {
            e.ToTable("reading_paper_artifact_heads");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.RunId, x.ArtifactId }).IsUnique();
        });

        mb.Entity<ReadingPaperArtifactDependency>(e =>
        {
            e.ToTable("reading_paper_artifact_dependencies");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.RunId, x.ArtifactId, x.Version });
            e.HasIndex(x => new { x.RunId, x.ParentArtifactId, x.ParentVersion });
        });

        mb.Entity<ReadingPaperEvaluation>(e =>
        {
            e.ToTable("reading_paper_evaluations");
            e.HasKey(x => x.Id);
            e.Property(x => x.EvaluatorVersion).HasDefaultValue("1.0.0");
            e.HasIndex(x => new { x.RunId, x.EvaluationId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.TargetArtifactId, x.TargetVersion });
        });

        mb.Entity<ReadingPaperIssue>(e =>
        {
            e.ToTable("reading_paper_issues");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.RunId, x.EvaluationId });
            e.HasIndex(x => new { x.RunId, x.IssueId }).IsUnique();
        });

        mb.Entity<ReadingPaperDecision>(e =>
        {
            e.ToTable("reading_paper_decisions");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.RunId, x.DecisionId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.EvaluationRef });
        });

        mb.Entity<ReadingPaperOperation>(e =>
        {
            e.ToTable("reading_paper_operations");
            e.HasKey(x => x.Id);
            e.Property(x => x.AccountingType).HasMaxLength(24);
            e.Property(x => x.CostReservationUsd).HasColumnType("numeric(12,4)").HasDefaultValue(0m);
            e.Property(x => x.CostUsedUsd).HasColumnType("numeric(12,4)").HasDefaultValue(0m);
            e.Property(x => x.TokensUsed).HasDefaultValue(0);
            e.Property(x => x.WallTimeReservationSeconds).HasDefaultValue(60.0);
            e.Property(x => x.WallTimeUsedSeconds).HasDefaultValue(0.0);
            e.HasIndex(x => new { x.RunId, x.ArtifactId });
            e.HasIndex(x => new { x.RunId, x.OperationId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.ParentOperationId });
            e.HasIndex(x => new { x.RunId, x.RequestHash });
            e.HasIndex(x => new { x.RunId, x.SectionId });
        });

        mb.Entity<ReadingPaperLoopCursor>(e =>
        {
            e.ToTable("reading_paper_loop_cursors");
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.RunId, x.ArtifactId }).IsUnique();
        });

        mb.Entity<ReadingPaperEventOutbox>(e =>
        {
            e.ToTable("reading_paper_event_outbox");
            e.HasKey(x => x.Id);
            e.Property(x => x.Epoch).HasDefaultValue(1);
            e.Property(x => x.Sequence).HasDefaultValue(0L);
            e.HasIndex(x => new { x.RunId, x.EventId }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.IdempotencyKey }).IsUnique();
            e.HasIndex(x => new { x.RunId, x.Sequence }).IsUnique();
            e.HasIndex(x => new { x.Status, x.CreatedAt });
        });

        mb.Entity<ReadingPaperBudgetAllocation>(e =>
        {
            e.ToTable("reading_paper_budget_allocations");
            e.HasKey(x => x.Id);
            e.Property(x => x.CallCap).HasDefaultValue(5);
            e.Property(x => x.WallTimeCapSeconds).HasDefaultValue(300);
            e.HasIndex(x => new { x.RunId, x.ParentScopeId });
            e.HasIndex(x => new { x.RunId, x.ScopeId }).IsUnique();
        });

        mb.Entity<ReadingPaperEntityLineage>(e =>
        {
            e.ToTable("reading_paper_entity_lineage");
            e.HasKey(x => x.Id);
            e.Property(x => x.ArtifactId).HasMaxLength(128);
            e.Property(x => x.ArtifactType).HasMaxLength(64);
            e.Property(x => x.ArtifactVersion).HasDefaultValue(1);
            e.Property(x => x.ContentHash).HasMaxLength(128);
            e.Property(x => x.EntityId).HasMaxLength(128);
            e.Property(x => x.EntityType).HasMaxLength(64);
            e.Property(x => x.RunId).HasMaxLength(128);
            e.HasIndex(x => x.ExamId);
            e.HasIndex(x => new { x.EntityType, x.EntityId });
            e.HasIndex(x => new { x.RunId, x.EntityType, x.EntityId }).IsUnique();
        });

        mb.Entity<ReadingPaperHumanFeedback>(e =>
        {
            e.ToTable("reading_paper_human_feedback");
            e.HasKey(x => x.Id);
            e.Property(x => x.FeedbackId).HasMaxLength(128);
            e.Property(x => x.RunId).HasMaxLength(128);
            e.Property(x => x.TargetEntityType).HasMaxLength(64);
            e.Property(x => x.TargetEntityId).HasMaxLength(128);
            e.Property(x => x.ArtifactId).HasMaxLength(128);
            e.Property(x => x.BeforeContentHash).HasMaxLength(128);
            e.Property(x => x.AfterContentHash).HasMaxLength(128);
            e.Property(x => x.EditorId).HasMaxLength(128);
            e.Property(x => x.EditorRole).HasMaxLength(64).HasDefaultValue("ADMIN");
            e.Property(x => x.Comment).HasMaxLength(4000);
            e.Property(x => x.ActionType).HasMaxLength(32);
            e.Property(x => x.CurationStatus).HasMaxLength(32).HasDefaultValue("RAW");
            e.Property(x => x.IdempotencyKey).HasMaxLength(256);
            e.HasIndex(x => x.CurationStatus);
            e.HasIndex(x => x.ExamId);
            e.HasIndex(x => x.FeedbackId).IsUnique();
            e.HasIndex(x => x.IdempotencyKey).IsUnique();
            e.HasIndex(x => x.RunId);
            e.HasIndex(x => new { x.TargetEntityType, x.TargetEntityId });
        });

        mb.Entity<ReadingPaperFeedbackCurationRecord>(e =>
        {
            e.ToTable("reading_paper_feedback_curation_records");
            e.HasKey(x => x.Id);
            e.Property(x => x.ReviewId).HasMaxLength(128);
            e.Property(x => x.FeedbackId).HasMaxLength(128);
            e.Property(x => x.FromStatus).HasMaxLength(32);
            e.Property(x => x.ToStatus).HasMaxLength(32);
            e.Property(x => x.ReviewerId).HasMaxLength(128);
            e.Property(x => x.ReviewerRole).HasMaxLength(64).HasDefaultValue("ADMIN");
            e.Property(x => x.ReviewNotes).HasMaxLength(4000);
            e.Property(x => x.Action).HasMaxLength(64);
            e.Property(x => x.IdempotencyKey).HasMaxLength(256);
            e.HasIndex(x => x.FeedbackId);
            e.HasIndex(x => x.ReviewId).IsUnique();
            e.HasIndex(x => new { x.FeedbackId, x.ReviewedAt });
        });
    }
}
