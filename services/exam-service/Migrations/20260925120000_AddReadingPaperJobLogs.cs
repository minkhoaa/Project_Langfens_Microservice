using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using exam_service.Infrastructure.Persistence;

#nullable disable

namespace exam_service.Migrations;

[DbContext(typeof(ExamDbContext))]
[Migration("20260925120000_AddReadingPaperJobLogs")]
public sealed class AddReadingPaperJobLogs : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "Logs",
            table: "reading_paper_jobs",
            type: "text",
            nullable: false,
            defaultValue: "");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
        => migrationBuilder.DropColumn(name: "Logs", table: "reading_paper_jobs");
}
