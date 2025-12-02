using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace writing_service.Migrations
{
    /// <inheritdoc />
    public partial class InitDb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "writing_exams",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    TaskText = table.Column<string>(type: "text", nullable: false),
                    ExamType = table.Column<int>(type: "integer", nullable: false),
                    Level = table.Column<string>(type: "text", nullable: true),
                    Tags = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_writing_exams", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "writing_submissions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: true),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: true),
                    TaskTextSnapshot = table.Column<string>(type: "text", nullable: false),
                    EssayRaw = table.Column<string>(type: "text", nullable: false),
                    EssayNormalized = table.Column<string>(type: "text", nullable: false),
                    WordCount = table.Column<int>(type: "integer", nullable: false),
                    ExamType = table.Column<int>(type: "integer", nullable: false),
                    Level = table.Column<string>(type: "text", nullable: true),
                    TimeSpentSeconds = table.Column<int>(type: "integer", nullable: true),
                    SubmittedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_writing_submissions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_writing_submissions_writing_exams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "writing_exams",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "writing_evaluation",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubmissionId = table.Column<Guid>(type: "uuid", nullable: false),
                    OverallBand = table.Column<double>(type: "double precision", nullable: false),
                    TaskResponseBand = table.Column<double>(type: "double precision", nullable: false),
                    TaskResponseComment = table.Column<string>(type: "text", nullable: false),
                    CoherenceAndCohesionBand = table.Column<double>(type: "double precision", nullable: false),
                    CoherenceAndCohesionComment = table.Column<string>(type: "text", nullable: false),
                    LexicalResourceBand = table.Column<double>(type: "double precision", nullable: false),
                    LexicalResourceComment = table.Column<string>(type: "text", nullable: false),
                    GrammaticalRangeAndAccuracyBand = table.Column<double>(type: "double precision", nullable: false),
                    GrammaticalRangeAndAccuracyComment = table.Column<string>(type: "text", nullable: false),
                    SuggestionsJson = table.Column<string>(type: "text", nullable: false),
                    ImprovedParagraph = table.Column<string>(type: "text", nullable: false),
                    Model = table.Column<string>(type: "text", nullable: false),
                    Provider = table.Column<string>(type: "text", nullable: false),
                    PromptSchemaVersion = table.Column<string>(type: "text", nullable: false),
                    RawLlmJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_writing_evaluation", x => x.Id);
                    table.ForeignKey(
                        name: "FK_writing_evaluation_writing_submissions_SubmissionId",
                        column: x => x.SubmissionId,
                        principalTable: "writing_submissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_writing_evaluation_SubmissionId",
                table: "writing_evaluation",
                column: "SubmissionId");

            migrationBuilder.CreateIndex(
                name: "IX_writing_submissions_ExamId",
                table: "writing_submissions",
                column: "ExamId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "writing_evaluation");

            migrationBuilder.DropTable(
                name: "writing_submissions");

            migrationBuilder.DropTable(
                name: "writing_exams");
        }
    }
}
