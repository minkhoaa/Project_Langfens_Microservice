using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace gamification_service.Migrations
{
    /// <inheritdoc />
    public partial class AddNotificationSettingsColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "EnableLevelUp",
                table: "UserNotificationSettings",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "EnableTestCompleted",
                table: "UserNotificationSettings",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "EnableWelcome",
                table: "UserNotificationSettings",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EnableLevelUp",
                table: "UserNotificationSettings");

            migrationBuilder.DropColumn(
                name: "EnableTestCompleted",
                table: "UserNotificationSettings");

            migrationBuilder.DropColumn(
                name: "EnableWelcome",
                table: "UserNotificationSettings");
        }
    }
}
