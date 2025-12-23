using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace writing_service.Migrations
{
    /// <inheritdoc />
    public partial class UpdateAddImageUrl : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "writing_exams",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Slug",
                table: "writing_exams",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "writing_exams");

            migrationBuilder.DropColumn(
                name: "Slug",
                table: "writing_exams");
        }
    }
}
