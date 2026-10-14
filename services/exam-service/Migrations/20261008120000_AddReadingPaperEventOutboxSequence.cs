using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddReadingPaperEventOutboxSequence : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "Sequence",
                table: "reading_paper_event_outbox",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.Sql(@"
                WITH numbered AS (
                    SELECT ""Id"", ROW_NUMBER() OVER (PARTITION BY ""RunId"" ORDER BY ""CreatedAt"", ""Id"") AS new_seq
                    FROM ""reading_paper_event_outbox""
                )
                UPDATE ""reading_paper_event_outbox"" e
                SET ""Sequence"" = n.new_seq
                FROM numbered n
                WHERE e.""Id"" = n.""Id"";
            ");

            migrationBuilder.CreateIndex(
                name: "IX_reading_paper_event_outbox_RunId_Sequence",
                table: "reading_paper_event_outbox",
                columns: new[] { "RunId", "Sequence" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_reading_paper_event_outbox_RunId_Sequence",
                table: "reading_paper_event_outbox");

            migrationBuilder.DropColumn(
                name: "Sequence",
                table: "reading_paper_event_outbox");
        }
    }
}
