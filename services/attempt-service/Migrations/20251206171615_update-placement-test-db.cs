using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class updateplacementtestdb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ListeningTotal",
                table: "placement_result",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "ReadingTotal",
                table: "placement_result",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ListeningTotal",
                table: "placement_result");

            migrationBuilder.DropColumn(
                name: "ReadingTotal",
                table: "placement_result");
        }
    }
}
