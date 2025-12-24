using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddQuestionGroup : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "GroupId",
                table: "exam_questions",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "exam_question_groups",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SectionId = table.Column<Guid>(type: "uuid", nullable: false),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    StartIdx = table.Column<int>(type: "integer", nullable: false),
                    EndIdx = table.Column<int>(type: "integer", nullable: false),
                    InstructionMd = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exam_question_groups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_exam_question_groups_exam_sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "exam_sections",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_exam_questions_GroupId",
                table: "exam_questions",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "IX_exam_question_groups_SectionId_Idx",
                table: "exam_question_groups",
                columns: new[] { "SectionId", "Idx" });

            migrationBuilder.AddForeignKey(
                name: "FK_exam_questions_exam_question_groups_GroupId",
                table: "exam_questions",
                column: "GroupId",
                principalTable: "exam_question_groups",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_exam_questions_exam_question_groups_GroupId",
                table: "exam_questions");

            migrationBuilder.DropTable(
                name: "exam_question_groups");

            migrationBuilder.DropIndex(
                name: "IX_exam_questions_GroupId",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "GroupId",
                table: "exam_questions");
        }
    }
}
