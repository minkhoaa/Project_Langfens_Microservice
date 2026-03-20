using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace writing_service.Migrations
{
    /// <inheritdoc />
    public partial class AddComparativeAnalysisJson : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ComparativeAnalysisJson",
                table: "writing_evaluation",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ComparativeAnalysisJson",
                table: "writing_evaluation");
        }
    }
}
