using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class updatedb2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "SpeakingBand",
                table: "placement_result",
                type: "numeric",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SpeakingBand",
                table: "placement_result");
        }
    }
}
