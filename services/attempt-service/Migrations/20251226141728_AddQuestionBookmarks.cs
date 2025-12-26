using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class AddQuestionBookmarks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "question_bookmarks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    QuestionId = table.Column<Guid>(type: "uuid", nullable: false),
                    Note = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_question_bookmarks", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "idx_bookmark_created",
                table: "question_bookmarks",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "idx_bookmark_user",
                table: "question_bookmarks",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "uq_bookmark_user_question",
                table: "question_bookmarks",
                columns: new[] { "UserId", "QuestionId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "question_bookmarks");
        }
    }
}
