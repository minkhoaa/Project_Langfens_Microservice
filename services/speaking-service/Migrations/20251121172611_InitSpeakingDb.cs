using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace speaking_service.Migrations
{
    /// <inheritdoc />
    public partial class InitSpeakingDb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "speaking_exams",
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
                    table.PrimaryKey("PK_speaking_exams", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "speaking_submissions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: true),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: true),
                    TaskTextSnapshot = table.Column<string>(type: "text", nullable: false),
                    TranscriptRaw = table.Column<string>(type: "text", nullable: false),
                    TranscriptNormalized = table.Column<string>(type: "text", nullable: false),
                    WordCount = table.Column<int>(type: "integer", nullable: false),
                    ExamType = table.Column<int>(type: "integer", nullable: false),
                    Level = table.Column<string>(type: "text", nullable: true),
                    TimeSpentSeconds = table.Column<int>(type: "integer", nullable: true),
                    SubmittedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_speaking_submissions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_speaking_submissions_speaking_exams_ExamId",
                        column: x => x.ExamId,
                        principalTable: "speaking_exams",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "speaking_evaluations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    SubmissionId = table.Column<Guid>(type: "uuid", nullable: false),
                    OverallBand = table.Column<double>(type: "double precision", nullable: false),
                    FluencyAndCoherenceBand = table.Column<double>(type: "double precision", nullable: false),
                    FluencyAndCoherenceComment = table.Column<string>(type: "text", nullable: false),
                    LexicalResourceBand = table.Column<double>(type: "double precision", nullable: false),
                    LexicalResourceComment = table.Column<string>(type: "text", nullable: false),
                    GrammaticalRangeAndAccuracyBand = table.Column<double>(type: "double precision", nullable: false),
                    GrammaticalRangeAndAccuracyComment = table.Column<string>(type: "text", nullable: false),
                    PronunciationBand = table.Column<double>(type: "double precision", nullable: false),
                    PronunciationComment = table.Column<string>(type: "text", nullable: false),
                    SuggestionsJson = table.Column<string>(type: "text", nullable: false),
                    ImprovedAnswer = table.Column<string>(type: "text", nullable: false),
                    Model = table.Column<string>(type: "text", nullable: false),
                    Provider = table.Column<string>(type: "text", nullable: false),
                    PromptSchemaVersion = table.Column<string>(type: "text", nullable: false),
                    RawLlmJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_speaking_evaluations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_speaking_evaluations_speaking_submissions_SubmissionId",
                        column: x => x.SubmissionId,
                        principalTable: "speaking_submissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_speaking_evaluations_SubmissionId",
                table: "speaking_evaluations",
                column: "SubmissionId");

            migrationBuilder.CreateIndex(
                name: "IX_speaking_submissions_ExamId",
                table: "speaking_submissions",
                column: "ExamId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "speaking_evaluations");

            migrationBuilder.DropTable(
                name: "speaking_submissions");

            migrationBuilder.DropTable(
                name: "speaking_exams");
        }
    }
}
