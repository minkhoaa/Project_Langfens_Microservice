using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace writing_service.Migrations
{
    /// <inheritdoc />
    public partial class AddSourceExamIdToWritingExam : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SourceExamId",
                table: "writing_exams",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SourceSectionId",
                table: "writing_exams",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SourceExamId",
                table: "writing_exams");

            migrationBuilder.DropColumn(
                name: "SourceSectionId",
                table: "writing_exams");
        }
    }
}
