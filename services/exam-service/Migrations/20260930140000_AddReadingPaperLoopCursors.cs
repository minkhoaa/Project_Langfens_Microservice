using System;
using exam_service.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations;

[DbContext(typeof(ExamDbContext))]
[Migration("20260930140000_AddReadingPaperLoopCursors")]
public sealed class AddReadingPaperLoopCursors : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "EnvelopeJson", table: "reading_paper_artifacts", type: "text", nullable: true);
        migrationBuilder.CreateTable(
            name: "reading_paper_loop_cursors",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                RunId = table.Column<string>(type: "text", nullable: false),
                ArtifactId = table.Column<string>(type: "text", nullable: false),
                Revision = table.Column<int>(type: "integer", nullable: false),
                StateJson = table.Column<string>(type: "text", nullable: false),
                LastOperationId = table.Column<string>(type: "text", nullable: true),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table => table.PrimaryKey("PK_reading_paper_loop_cursors", x => x.Id));
        migrationBuilder.CreateIndex(
            name: "IX_reading_paper_loop_cursors_RunId_ArtifactId",
            table: "reading_paper_loop_cursors", columns: new[] { "RunId", "ArtifactId" }, unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Application-first rollback: retain durable V2 cursor/envelope data.
    }
}
