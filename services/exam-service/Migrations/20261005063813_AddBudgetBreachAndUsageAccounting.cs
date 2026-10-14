using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddBudgetBreachAndUsageAccounting : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "BudgetBreachDetected",
                table: "reading_paper_runs",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "BudgetBreachReason",
                table: "reading_paper_runs",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BudgetProfileJson",
                table: "reading_paper_runs",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BudgetProfileSha256",
                table: "reading_paper_runs",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BudgetProfileSource",
                table: "reading_paper_runs",
                type: "character varying(256)",
                maxLength: 256,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BudgetProfileVersion",
                table: "reading_paper_runs",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "AccountingType",
                table: "reading_paper_operations",
                type: "character varying(24)",
                maxLength: 24,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BudgetBreachReason",
                table: "reading_paper_operations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompletionTokensUsed",
                table: "reading_paper_operations",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PromptTokensUsed",
                table: "reading_paper_operations",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ReasoningTokensUsed",
                table: "reading_paper_operations",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "ReservationBreached",
                table: "reading_paper_operations",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "BudgetBreachDetected",
                table: "reading_paper_benchmark_campaigns",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "BudgetBreachReason",
                table: "reading_paper_benchmark_campaigns",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BudgetBreachDetected",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BudgetBreachReason",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BudgetProfileJson",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BudgetProfileSha256",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BudgetProfileSource",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "BudgetProfileVersion",
                table: "reading_paper_runs");

            migrationBuilder.DropColumn(
                name: "AccountingType",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "BudgetBreachReason",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "CompletionTokensUsed",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "PromptTokensUsed",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "ReasoningTokensUsed",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "ReservationBreached",
                table: "reading_paper_operations");

            migrationBuilder.DropColumn(
                name: "BudgetBreachDetected",
                table: "reading_paper_benchmark_campaigns");

            migrationBuilder.DropColumn(
                name: "BudgetBreachReason",
                table: "reading_paper_benchmark_campaigns");
        }
    }
}
