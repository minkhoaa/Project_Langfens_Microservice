using System;
using System.Text.Json;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class InitDb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "exams",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Slug = table.Column<string>(type: "text", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    DescriptionMd = table.Column<string>(type: "text", nullable: true),
                    Category = table.Column<string>(type: "text", nullable: false),
                    Level = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    DurationMin = table.Column<int>(type: "integer", nullable: false),
                    ImageUrl = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()"),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exams", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "exam_sections",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: false),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    InstructionsMd = table.Column<string>(type: "text", nullable: true),
                    PassageMd = table.Column<string>(type: "text", nullable: true),
                    AudioUrl = table.Column<string>(type: "text", nullable: true),
                    TranscriptMd = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exam_sections", x => x.Id);
                    table.ForeignKey(
                        name: "FK_exam_sections_exams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "exams",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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

            migrationBuilder.CreateTable(
                name: "exam_questions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SectionId = table.Column<Guid>(type: "uuid", nullable: false),
                    GroupId = table.Column<Guid>(type: "uuid", nullable: true),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    Skill = table.Column<string>(type: "text", nullable: false),
                    Payload = table.Column<JsonDocument>(type: "jsonb", nullable: false),
                    CorrectAnswer = table.Column<JsonDocument>(type: "jsonb", nullable: false),
                    SchemaVersion = table.Column<string>(type: "text", nullable: false, defaultValue: "1.0.0"),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExamQuestionGroupId = table.Column<Guid>(type: "uuid", nullable: true),
                    ExamSectionId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exam_questions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_exam_questions_exam_question_groups_ExamQuestionGroupId",
                        column: x => x.ExamQuestionGroupId,
                        principalTable: "exam_question_groups",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_exam_questions_exam_question_groups_GroupId",
                        column: x => x.GroupId,
                        principalTable: "exam_question_groups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_exam_questions_exam_sections_ExamSectionId",
                        column: x => x.ExamSectionId,
                        principalTable: "exam_sections",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_exam_questions_exam_sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "exam_sections",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "exam_options",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    QuestionId = table.Column<Guid>(type: "uuid", nullable: false),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    ContentMd = table.Column<string>(type: "text", nullable: false),
                    IsCorrect = table.Column<bool>(type: "boolean", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_exam_options", x => x.Id);
                    table.ForeignKey(
                        name: "FK_exam_options_exam_questions_QuestionId",
                        column: x => x.QuestionId,
                        principalTable: "exam_questions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_exam_options_QuestionId_Idx",
                table: "exam_options",
                columns: new[] { "QuestionId", "Idx" });

            migrationBuilder.CreateIndex(
                name: "IX_exam_question_groups_SectionId_Idx",
                table: "exam_question_groups",
                columns: new[] { "SectionId", "Idx" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_exam_questions_correct_answer_gin",
                table: "exam_questions",
                column: "CorrectAnswer")
                .Annotation("Npgsql:IndexMethod", "gin")
                .Annotation("Npgsql:IndexOperators", new[] { "jsonb_path_ops" });

            migrationBuilder.CreateIndex(
                name: "IX_exam_questions_ExamQuestionGroupId",
                table: "exam_questions",
                column: "ExamQuestionGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_exam_questions_ExamSectionId",
                table: "exam_questions",
                column: "ExamSectionId");

            migrationBuilder.CreateIndex(
                name: "IX_exam_questions_GroupId",
                table: "exam_questions",
                column: "GroupId");

            migrationBuilder.CreateIndex(
                name: "ix_exam_questions_payload_gin",
                table: "exam_questions",
                column: "Payload")
                .Annotation("Npgsql:IndexMethod", "gin")
                .Annotation("Npgsql:IndexOperators", new[] { "jsonb_path_ops" });

            migrationBuilder.CreateIndex(
                name: "IX_exam_questions_SectionId_Idx",
                table: "exam_questions",
                columns: new[] { "SectionId", "Idx" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_exam_sections_ExamId_Idx",
                table: "exam_sections",
                columns: new[] { "ExamId", "Idx" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_exams_Slug",
                table: "exams",
                column: "Slug",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "exam_options");

            migrationBuilder.DropTable(
                name: "exam_questions");

            migrationBuilder.DropTable(
                name: "exam_question_groups");

            migrationBuilder.DropTable(
                name: "exam_sections");

            migrationBuilder.DropTable(
                name: "exams");
        }
    }
}
