using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class AddImageUrlToOptionAndQuestion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "exam_questions",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AltText",
                table: "exam_options",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "exam_options",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "exam_questions");

            migrationBuilder.DropColumn(
                name: "AltText",
                table: "exam_options");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "exam_options");
        }
    }
}
