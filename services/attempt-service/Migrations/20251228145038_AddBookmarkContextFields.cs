using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class AddBookmarkContextFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "AttemptId",
                table: "question_bookmarks",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CorrectAnswer",
                table: "question_bookmarks",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AttemptId",
                table: "question_bookmarks");

            migrationBuilder.DropColumn(
                name: "CorrectAnswer",
                table: "question_bookmarks");
        }
    }
}
