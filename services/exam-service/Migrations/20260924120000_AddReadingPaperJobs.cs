using System;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using exam_service.Infrastructure.Persistence;

#nullable disable

namespace exam_service.Migrations;

[DbContext(typeof(ExamDbContext))]
[Migration("20260924120000_AddReadingPaperJobs")]
public sealed class AddReadingPaperJobs : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        foreach (var column in new[] { "SourcePmcid", "SourceTitle", "SourceAuthors", "SourceDoi", "SourceUrl", "SourceLicense" })
            migrationBuilder.AddColumn<string>(name: column, table: "exam_sections", type: "text", nullable: true);

        migrationBuilder.CreateTable(
            name: "reading_paper_jobs",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                Topic = table.Column<string>(type: "text", nullable: false),
                Status = table.Column<string>(type: "text", nullable: false),
                CompletedSections = table.Column<int>(type: "integer", nullable: false),
                SourcesJson = table.Column<string>(type: "text", nullable: false),
                SectionsJson = table.Column<string>(type: "text", nullable: false),
                Error = table.Column<string>(type: "text", nullable: true),
                ExamId = table.Column<Guid>(type: "uuid", nullable: true),
                LeaseUntil = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                LeaseOwner = table.Column<Guid>(type: "uuid", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table => table.PrimaryKey("PK_reading_paper_jobs", x => x.Id));
        migrationBuilder.CreateIndex("IX_reading_paper_jobs_Status_LeaseUntil", "reading_paper_jobs", new[] { "Status", "LeaseUntil" });
        migrationBuilder.CreateIndex("IX_reading_paper_jobs_ExamId", "reading_paper_jobs", "ExamId", unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable("reading_paper_jobs");
        foreach (var column in new[] { "SourcePmcid", "SourceTitle", "SourceAuthors", "SourceDoi", "SourceUrl", "SourceLicense" })
            migrationBuilder.DropColumn(name: column, table: "exam_sections");
    }
}
