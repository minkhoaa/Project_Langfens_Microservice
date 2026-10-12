using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddBenchmarkCampaignBudgets : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BenchmarkCampaignId",
                table: "reading_paper_runs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BenchmarkCaseId",
                table: "reading_paper_runs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BenchmarkClaimId",
                table: "reading_paper_runs",
                type: "text",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "reading_paper_benchmark_campaigns",
                columns: table => new
                {
                    CampaignId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    AuthorizationId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    AuthorizedBy = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CorpusSha256 = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    ConfigSha256 = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    BudgetCapCalls = table.Column<int>(type: "integer", nullable: false),
                    BudgetUsedCalls = table.Column<int>(type: "integer", nullable: false),
                    BudgetCapTokens = table.Column<int>(type: "integer", nullable: false),
                    BudgetUsedTokens = table.Column<int>(type: "integer", nullable: false),
                    BudgetCapWallTimeSeconds = table.Column<double>(type: "double precision", nullable: false),
                    BudgetUsedWallTimeSeconds = table.Column<double>(type: "double precision", nullable: false),
                    Status = table.Column<string>(type: "character varying(24)", maxLength: 24, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_paper_benchmark_campaigns", x => x.CampaignId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_runs_BenchmarkCampaignId_BenchmarkCaseId",
                table: "reading_paper_runs",
                columns: new[] { "BenchmarkCampaignId", "BenchmarkCaseId" },
                unique: true,
                filter: "\"BenchmarkCampaignId\" IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_benchmark_campaigns_Status",
                table: "reading_paper_benchmark_campaigns",
                column: "Status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "reading_paper_benchmark_campaigns");

            migrationBuilder.DropIndex(
                name: "IX_reading_paper_runs_BenchmarkCampaignId_BenchmarkCaseId",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BenchmarkCampaignId",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BenchmarkCaseId",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BenchmarkClaimId",
                table: "reading_paper_runs");
        }
    }
}
