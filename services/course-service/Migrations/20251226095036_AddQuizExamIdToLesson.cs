using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace course_service.Migrations
{
    /// <inheritdoc />
    public partial class AddQuizExamIdToLesson : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "QuizExamId",
                table: "lesson",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "QuizExamId",
                table: "lesson");
        }
    }
}
