using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddReadingPaperLineageAndFeedback : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "reading_paper_entity_lineage",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    RunId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: false),
                    SectionId = table.Column<Guid>(type: "uuid", nullable: true),
                    QuestionId = table.Column<Guid>(type: "uuid", nullable: true),
                    OptionId = table.Column<Guid>(type: "uuid", nullable: true),
                    EntityType = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    EntityId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ArtifactId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ArtifactType = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    ArtifactVersion = table.Column<int>(type: "integer", nullable: false, defaultValue: 1),
                    ContentHash = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ParentRefsJson = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_paper_entity_lineage", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "reading_paper_feedback_curation_records",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ReviewId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    FeedbackId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    FromStatus = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    ToStatus = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    ReviewerId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ReviewerRole = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false, defaultValue: "ADMIN"),
                    ReviewNotes = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    Action = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    IdempotencyKey = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_paper_feedback_curation_records", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "reading_paper_human_feedback",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    FeedbackId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    RunId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: true),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: false),
                    SectionId = table.Column<Guid>(type: "uuid", nullable: true),
                    QuestionId = table.Column<Guid>(type: "uuid", nullable: true),
                    OptionId = table.Column<Guid>(type: "uuid", nullable: true),
                    TargetEntityType = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    TargetEntityId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    ArtifactId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: true),
                    ArtifactVersion = table.Column<int>(type: "integer", nullable: true),
                    BeforeContentHash = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    AfterContentHash = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    BeforePayloadJson = table.Column<string>(type: "text", nullable: false),
                    AfterPayloadJson = table.Column<string>(type: "text", nullable: false),
                    DiffJson = table.Column<string>(type: "text", nullable: false),
                    EditorId = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    EditorRole = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false, defaultValue: "ADMIN"),
                    ReasonsJson = table.Column<string>(type: "text", nullable: false),
                    Comment = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    DownstreamImpactJson = table.Column<string>(type: "text", nullable: false),
                    ActionType = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    CurationStatus = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false, defaultValue: "RAW"),
                    IdempotencyKey = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_reading_paper_human_feedback", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_entity_lineage_EntityType_EntityId",
                table: "reading_paper_entity_lineage",
                columns: new[] { "EntityType", "EntityId" });

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_entity_lineage_ExamId",
                table: "reading_paper_entity_lineage",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_entity_lineage_RunId_EntityType_EntityId",
                table: "reading_paper_entity_lineage",
                columns: new[] { "RunId", "EntityType", "EntityId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_feedback_curation_records_FeedbackId",
                table: "reading_paper_feedback_curation_records",
                column: "FeedbackId");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_feedback_curation_records_FeedbackId_Reviewed~",
                table: "reading_paper_feedback_curation_records",
                columns: new[] { "FeedbackId", "ReviewedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_feedback_curation_records_ReviewId",
                table: "reading_paper_feedback_curation_records",
                column: "ReviewId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_CurationStatus",
                table: "reading_paper_human_feedback",
                column: "CurationStatus");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_ExamId",
                table: "reading_paper_human_feedback",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_FeedbackId",
                table: "reading_paper_human_feedback",
                column: "FeedbackId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_IdempotencyKey",
                table: "reading_paper_human_feedback",
                column: "IdempotencyKey",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_RunId",
                table: "reading_paper_human_feedback",
                column: "RunId");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_human_feedback_TargetEntityType_TargetEntityId",
                table: "reading_paper_human_feedback",
                columns: new[] { "TargetEntityType", "TargetEntityId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "reading_paper_entity_lineage");

            migrationBuilder.DropTable(
                name: "reading_paper_feedback_curation_records");

            migrationBuilder.DropTable(
                name: "reading_paper_human_feedback");
        }
    }
}
