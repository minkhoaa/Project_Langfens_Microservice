using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class AddGradeJsonFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SpeakingGradeJson",
                table: "placement_result",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "WritingGradeJson",
                table: "placement_result",
                type: "jsonb",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SpeakingGradeJson",
                table: "placement_result");

            migrationBuilder.DropColumn(
                name: "WritingGradeJson",
                table: "placement_result");
        }
    }
}
