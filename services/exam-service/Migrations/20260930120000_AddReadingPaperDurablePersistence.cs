using System;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using exam_service.Infrastructure.Persistence;

#nullable disable

namespace exam_service.Migrations;

[DbContext(typeof(ExamDbContext))]
[Migration("20260930120000_AddReadingPaperDurablePersistence")]
public sealed class AddReadingPaperDurablePersistence : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // 1. Additive columns to reading_paper_jobs
        migrationBuilder.AddColumn<int>(
            name: "Epoch",
            table: "reading_paper_jobs",
            type: "integer",
            nullable: false,
            defaultValue: 1);

        migrationBuilder.AddColumn<int>(
            name: "CancelVersion",
            table: "reading_paper_jobs",
            type: "integer",
            nullable: false,
            defaultValue: 0);

        migrationBuilder.AddColumn<string>(
            name: "EngineVersion",
            table: "reading_paper_jobs",
            type: "text",
            nullable: false,
            defaultValue: "2.0.0");

        migrationBuilder.AddColumn<string>(
            name: "SchemaVersion",
            table: "reading_paper_jobs",
            type: "text",
            nullable: false,
            defaultValue: "2.0.0");

        migrationBuilder.AddColumn<string>(
            name: "PolicyVersion",
            table: "reading_paper_jobs",
            type: "text",
            nullable: false,
            defaultValue: "2.0.0");

        migrationBuilder.AddColumn<string>(
            name: "ActiveRunId",
            table: "reading_paper_jobs",
            type: "text",
            nullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_jobs_Id_Epoch_LeaseOwner",
            table: "reading_paper_jobs",
            columns: new[] { "Id", "Epoch", "LeaseOwner" });

        // 2. reading_paper_runs
        migrationBuilder.CreateTable(
            name: "reading_paper_runs",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                JobId = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                Epoch = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                Status = table.Column<string>(type: "text", nullable: false),
                LeaseOwner = table.Column<Guid>(type: "uuid", nullable: true),
                LeaseUntil = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                CancelVersion = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                EngineVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "2.0.0"),
                SchemaVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "2.0.0"),
                PolicyVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "2.0.0"),
                SourceRevisionsJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                BudgetCapCalls = table.Column<int>(type: "integer", nullable: false, defaultValue: 25),
                BudgetCapTokens = table.Column<int>(type: "integer", nullable: false, defaultValue: 150000),
                BudgetUsedCalls = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                BudgetUsedTokens = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_runs", x => x.Id);
                table.ForeignKey(
                    name: "FK_reading_paper_runs_reading_paper_jobs_JobId",
                    column: x => x.JobId,
                    principalTable: "reading_paper_jobs",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_runs_JobId_RunId",
            table: "reading_paper_runs",
            columns: new[] { "JobId", "RunId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_runs_RunId",
            table: "reading_paper_runs",
            column: "RunId",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_runs_Status",
            table: "reading_paper_runs",
            column: "Status");

        // 3. reading_paper_artifacts
        migrationBuilder.CreateTable(
            name: "reading_paper_artifacts",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                ArtifactId = table.Column<string>(type: "text", nullable: false),
                ArtifactType = table.Column<string>(type: "text", nullable: false),
                Version = table.Column<int>(type: "integer", nullable: false),
                ContentHash = table.Column<string>(type: "text", nullable: false),
                PayloadJson = table.Column<string>(type: "text", nullable: false),
                ParentRefsJson = table.Column<string>(type: "text", nullable: false, defaultValue: "[]"),
                ProducerVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "2.0.0"),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_artifacts", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifacts_RunId_ArtifactId_Version",
            table: "reading_paper_artifacts",
            columns: new[] { "RunId", "ArtifactId", "Version" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifacts_RunId_ArtifactId",
            table: "reading_paper_artifacts",
            columns: new[] { "RunId", "ArtifactId" });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifacts_ContentHash",
            table: "reading_paper_artifacts",
            column: "ContentHash");

        // 4. reading_paper_artifact_heads
        migrationBuilder.CreateTable(
            name: "reading_paper_artifact_heads",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                ArtifactId = table.Column<string>(type: "text", nullable: false),
                AcceptedVersion = table.Column<int>(type: "integer", nullable: false),
                AcceptedHash = table.Column<string>(type: "text", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_artifact_heads", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifact_heads_RunId_ArtifactId",
            table: "reading_paper_artifact_heads",
            columns: new[] { "RunId", "ArtifactId" },
            unique: true);

        // 5. reading_paper_artifact_dependencies
        migrationBuilder.CreateTable(
            name: "reading_paper_artifact_dependencies",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                ArtifactId = table.Column<string>(type: "text", nullable: false),
                Version = table.Column<int>(type: "integer", nullable: false),
                ParentArtifactId = table.Column<string>(type: "text", nullable: false),
                ParentVersion = table.Column<int>(type: "integer", nullable: false),
                ParentContentHash = table.Column<string>(type: "text", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_artifact_dependencies", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifact_dependencies_RunId_ArtifactId_Version",
            table: "reading_paper_artifact_dependencies",
            columns: new[] { "RunId", "ArtifactId", "Version" });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_artifact_dependencies_RunId_ParentArtifactId_ParentVersion",
            table: "reading_paper_artifact_dependencies",
            columns: new[] { "RunId", "ParentArtifactId", "ParentVersion" });

        // 6. reading_paper_evaluations
        migrationBuilder.CreateTable(
            name: "reading_paper_evaluations",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                EvaluationId = table.Column<string>(type: "text", nullable: false),
                EvaluatorId = table.Column<string>(type: "text", nullable: false),
                EvaluatorVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "1.0.0"),
                TargetArtifactId = table.Column<string>(type: "text", nullable: false),
                TargetVersion = table.Column<int>(type: "integer", nullable: false),
                TargetContentHash = table.Column<string>(type: "text", nullable: false),
                Status = table.Column<string>(type: "text", nullable: false),
                IsPass = table.Column<bool>(type: "boolean", nullable: false),
                PayloadJson = table.Column<string>(type: "text", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_evaluations", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_evaluations_RunId_EvaluationId",
            table: "reading_paper_evaluations",
            columns: new[] { "RunId", "EvaluationId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_evaluations_RunId_TargetArtifactId_TargetVersion",
            table: "reading_paper_evaluations",
            columns: new[] { "RunId", "TargetArtifactId", "TargetVersion" });

        // 7. reading_paper_issues
        migrationBuilder.CreateTable(
            name: "reading_paper_issues",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                IssueId = table.Column<string>(type: "text", nullable: false),
                EvaluationId = table.Column<string>(type: "text", nullable: false),
                Code = table.Column<string>(type: "text", nullable: false),
                Severity = table.Column<string>(type: "text", nullable: false),
                Scope = table.Column<string>(type: "text", nullable: false),
                Message = table.Column<string>(type: "text", nullable: false),
                Status = table.Column<string>(type: "text", nullable: false),
                Fingerprint = table.Column<string>(type: "text", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_issues", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_issues_RunId_IssueId",
            table: "reading_paper_issues",
            columns: new[] { "RunId", "IssueId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_issues_RunId_EvaluationId",
            table: "reading_paper_issues",
            columns: new[] { "RunId", "EvaluationId" });

        // 8. reading_paper_decisions
        migrationBuilder.CreateTable(
            name: "reading_paper_decisions",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                DecisionId = table.Column<string>(type: "text", nullable: false),
                Decision = table.Column<string>(type: "text", nullable: false),
                CurrentState = table.Column<string>(type: "text", nullable: false),
                NextState = table.Column<string>(type: "text", nullable: false),
                Reason = table.Column<string>(type: "text", nullable: false),
                TargetScope = table.Column<string>(type: "text", nullable: false),
                EvaluationRef = table.Column<string>(type: "text", nullable: true),
                BudgetReservationId = table.Column<string>(type: "text", nullable: true),
                ExpectedVersion = table.Column<int>(type: "integer", nullable: true),
                PayloadJson = table.Column<string>(type: "text", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_decisions", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_decisions_RunId_DecisionId",
            table: "reading_paper_decisions",
            columns: new[] { "RunId", "DecisionId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_decisions_RunId_EvaluationRef",
            table: "reading_paper_decisions",
            columns: new[] { "RunId", "EvaluationRef" });

        // 9. reading_paper_operations
        migrationBuilder.CreateTable(
            name: "reading_paper_operations",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                OperationId = table.Column<string>(type: "text", nullable: false),
                OperationType = table.Column<string>(type: "text", nullable: false),
                RequestHash = table.Column<string>(type: "text", nullable: false),
                Status = table.Column<string>(type: "text", nullable: false),
                TokenReservation = table.Column<int>(type: "integer", nullable: false),
                TokensUsed = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                CostReservationUsd = table.Column<decimal>(type: "numeric(12,4)", nullable: false, defaultValue: 0m),
                CostUsedUsd = table.Column<decimal>(type: "numeric(12,4)", nullable: false, defaultValue: 0m),
                ResultRefJson = table.Column<string>(type: "text", nullable: true),
                ErrorMessage = table.Column<string>(type: "text", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_operations", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_operations_RunId_OperationId",
            table: "reading_paper_operations",
            columns: new[] { "RunId", "OperationId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_operations_RunId_RequestHash",
            table: "reading_paper_operations",
            columns: new[] { "RunId", "RequestHash" });

        // 10. reading_paper_event_outbox
        migrationBuilder.CreateTable(
            name: "reading_paper_event_outbox",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                EventId = table.Column<string>(type: "text", nullable: false),
                EventType = table.Column<string>(type: "text", nullable: false),
                IdempotencyKey = table.Column<string>(type: "text", nullable: false),
                Epoch = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                PayloadJson = table.Column<string>(type: "text", nullable: false),
                Status = table.Column<string>(type: "text", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                PublishedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_event_outbox", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_event_outbox_RunId_EventId",
            table: "reading_paper_event_outbox",
            columns: new[] { "RunId", "EventId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_event_outbox_RunId_IdempotencyKey",
            table: "reading_paper_event_outbox",
            columns: new[] { "RunId", "IdempotencyKey" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_event_outbox_Status_CreatedAt",
            table: "reading_paper_event_outbox",
            columns: new[] { "Status", "CreatedAt" });
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "reading_paper_event_outbox");
        migrationBuilder.DropTable(name: "reading_paper_operations");
        migrationBuilder.DropTable(name: "reading_paper_decisions");
        migrationBuilder.DropTable(name: "reading_paper_issues");
        migrationBuilder.DropTable(name: "reading_paper_evaluations");
        migrationBuilder.DropTable(name: "reading_paper_artifact_dependencies");
        migrationBuilder.DropTable(name: "reading_paper_artifact_heads");
        migrationBuilder.DropTable(name: "reading_paper_artifacts");
        migrationBuilder.DropTable(name: "reading_paper_runs");

        migrationBuilder.DropIndex(
            name: "IX_reading_paper_jobs_Id_Epoch_LeaseOwner",
            table: "reading_paper_jobs");

        migrationBuilder.DropColumn(name: "ActiveRunId", table: "reading_paper_jobs");
        migrationBuilder.DropColumn(name: "PolicyVersion", table: "reading_paper_jobs");
        migrationBuilder.DropColumn(name: "SchemaVersion", table: "reading_paper_jobs");
        migrationBuilder.DropColumn(name: "EngineVersion", table: "reading_paper_jobs");
        migrationBuilder.DropColumn(name: "CancelVersion", table: "reading_paper_jobs");
        migrationBuilder.DropColumn(name: "Epoch", table: "reading_paper_jobs");
    }
}
