using System;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using exam_service.Infrastructure.Persistence;

#nullable disable

namespace exam_service.Migrations;

[DbContext(typeof(ExamDbContext))]
[Migration("20260930130000_AddReadingPaperBudgetAllocations")]
public sealed class AddReadingPaperBudgetAllocations : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // 1. Additive wall-time columns to reading_paper_runs
        migrationBuilder.AddColumn<int>(
            name: "BudgetCapWallTimeSeconds",
            table: "reading_paper_runs",
            type: "integer",
            nullable: false,
            defaultValue: 900);

        migrationBuilder.AddColumn<double>(
            name: "BudgetUsedWallTimeSeconds",
            table: "reading_paper_runs",
            type: "double precision",
            nullable: false,
            defaultValue: 0.0);

        // 2. Additive hierarchy and wall-time columns to reading_paper_operations
        migrationBuilder.AddColumn<string>(
            name: "SectionId",
            table: "reading_paper_operations",
            type: "text",
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "ArtifactId",
            table: "reading_paper_operations",
            type: "text",
            nullable: true);
        migrationBuilder.AddColumn<string>(
            name: "ParentOperationId",
            table: "reading_paper_operations",
            type: "text",
            nullable: true);


        migrationBuilder.AddColumn<double>(
            name: "WallTimeReservationSeconds",
            table: "reading_paper_operations",
            type: "double precision",
            nullable: false,
            defaultValue: 60.0);

        migrationBuilder.AddColumn<double>(
            name: "WallTimeUsedSeconds",
            table: "reading_paper_operations",
            type: "double precision",
            nullable: false,
            defaultValue: 0.0);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_operations_RunId_SectionId",
            table: "reading_paper_operations",
            columns: new[] { "RunId", "SectionId" });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_operations_RunId_ArtifactId",
            table: "reading_paper_operations",
            columns: new[] { "RunId", "ArtifactId" });
        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_operations_RunId_ParentOperationId",
            table: "reading_paper_operations",
            columns: new[] { "RunId", "ParentOperationId" });


        // 3. Create reading_paper_budget_allocations table
        migrationBuilder.CreateTable(
            name: "reading_paper_budget_allocations",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                ScopeType = table.Column<string>(type: "text", nullable: false),
                ScopeId = table.Column<string>(type: "text", nullable: false),
                ParentScopeId = table.Column<string>(type: "text", nullable: true),
                TokenCap = table.Column<int>(type: "integer", nullable: false),
                CallCap = table.Column<int>(type: "integer", nullable: false, defaultValue: 5),
                WallTimeCapSeconds = table.Column<int>(type: "integer", nullable: false, defaultValue: 300),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_reading_paper_budget_allocations", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_budget_allocations_RunId_ScopeId",
            table: "reading_paper_budget_allocations",
            columns: new[] { "RunId", "ScopeId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_budget_allocations_RunId_ParentScopeId",
            table: "reading_paper_budget_allocations",
            columns: new[] { "RunId", "ParentScopeId" });
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Application-first rollback policy:
        // Destructive schema drop is prohibited by policy to protect additive persistent data and budgets.
    }
}
