using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class UpdateAddImageUrl : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "exams",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "exams");
        }
    }
}
