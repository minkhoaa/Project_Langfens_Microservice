using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace speaking_service.Migrations
{
    /// <inheritdoc />
    public partial class AddImageUrlToSpeakingExam : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "speaking_exams",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "speaking_exams");
        }
    }
}
