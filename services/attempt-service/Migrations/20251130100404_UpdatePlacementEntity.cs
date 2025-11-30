using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePlacementEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "placement_result",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    ExamId = table.Column<Guid>(type: "uuid", nullable: false),
                    AttemptId = table.Column<Guid>(type: "uuid", nullable: false),
                    PlacementLevel = table.Column<string>(type: "text", nullable: false),
                    PlacementBand = table.Column<string>(type: "text", nullable: false),
                    ReadingCorrect = table.Column<int>(type: "integer", nullable: false),
                    ListeningCorrect = table.Column<int>(type: "integer", nullable: false),
                    WritingBand = table.Column<decimal>(type: "numeric", nullable: false),
                    TotalCorrect = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_placement_result", x => x.Id);
                    table.ForeignKey(
                        name: "FK_placement_result_attempts_AttemptId",
                        column: x => x.AttemptId,
                        principalTable: "attempts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_AttemptId",
                table: "placement_result",
                column: "AttemptId");

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_ExamId",
                table: "placement_result",
                column: "ExamId");

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_UserId_CreatedAt",
                table: "placement_result",
                columns: new[] { "UserId", "CreatedAt" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "placement_result");
        }
    }
}
