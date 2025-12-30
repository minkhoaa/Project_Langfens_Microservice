using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace gamification_service.Migrations
{
    /// <inheritdoc />
    public partial class AddDisplayNameToUserStats : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DisplayName",
                table: "UserStats",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DisplayName",
                table: "UserStats");
        }
    }
}
