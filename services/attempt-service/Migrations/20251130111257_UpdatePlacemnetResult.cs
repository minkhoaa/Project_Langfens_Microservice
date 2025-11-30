using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePlacemnetResult : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_placement_result_AttemptId",
                table: "placement_result");

            migrationBuilder.DropIndex(
                name: "IX_placement_result_UserId_CreatedAt",
                table: "placement_result");

            migrationBuilder.DropColumn(
                name: "PlacementBand",
                table: "placement_result");

            migrationBuilder.RenameColumn(
                name: "PlacementLevel",
                table: "placement_result",
                newName: "Level");

            migrationBuilder.AddColumn<decimal>(
                name: "Band",
                table: "placement_result",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_AttemptId",
                table: "placement_result",
                column: "AttemptId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_UserId_CreatedAt",
                table: "placement_result",
                columns: new[] { "UserId", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_placement_result_AttemptId",
                table: "placement_result");

            migrationBuilder.DropIndex(
                name: "IX_placement_result_UserId_CreatedAt",
                table: "placement_result");

            migrationBuilder.DropColumn(
                name: "Band",
                table: "placement_result");

            migrationBuilder.RenameColumn(
                name: "Level",
                table: "placement_result",
                newName: "PlacementLevel");

            migrationBuilder.AddColumn<string>(
                name: "PlacementBand",
                table: "placement_result",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_AttemptId",
                table: "placement_result",
                column: "AttemptId");

            migrationBuilder.CreateIndex(
                name: "IX_placement_result_UserId_CreatedAt",
                table: "placement_result",
                columns: new[] { "UserId", "CreatedAt" },
                unique: true);
        }
    }
}
