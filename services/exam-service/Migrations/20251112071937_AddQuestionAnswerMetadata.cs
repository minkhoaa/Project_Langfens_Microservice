using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddQuestionAnswerMetadata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Dictionary<string, string[]?>>(
                name: "BlankAcceptRegex",
                table: "exam_questions",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<Dictionary<string, string[]?>>(
                name: "BlankAcceptTexts",
                table: "exam_questions",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<Dictionary<string, string[]?>>(
                name: "MatchPairs",
                table: "exam_questions",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<List<string>>(
                name: "OrderCorrects",
                table: "exam_questions",
                type: "text[]",
                nullable: true);

            migrationBuilder.AddColumn<List<string>>(
                name: "ShortAnswerAcceptRegex",
                table: "exam_questions",
                type: "text[]",
                nullable: true);

            migrationBuilder.AddColumn<List<string>>(
                name: "ShortAnswerAcceptTexts",
                table: "exam_questions",
                type: "text[]",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BlankAcceptRegex",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "BlankAcceptTexts",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "MatchPairs",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "OrderCorrects",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "ShortAnswerAcceptRegex",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "ShortAnswerAcceptTexts",
                table: "exam_questions");
        }
    }
}
