using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace course_service.Migrations
{
    /// <inheritdoc />
    public partial class initdb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "course",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Slug = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    DescriptionMd = table.Column<string>(type: "text", nullable: true),
                    Category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Level = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_course", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "enrollment",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    CourseId = table.Column<Guid>(type: "uuid", nullable: false),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    EnrolledAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_enrollment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_enrollment_course_CourseId",
                        column: x => x.CourseId,
                        principalTable: "course",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "lesson",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CourseId = table.Column<Guid>(type: "uuid", nullable: false),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    ContentMd = table.Column<string>(type: "text", nullable: true),
                    DurationMin = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson", x => x.Id);
                    table.ForeignKey(
                        name: "FK_lesson_course_CourseId",
                        column: x => x.CourseId,
                        principalTable: "course",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "lesson_completion",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    LessonId = table.Column<Guid>(type: "uuid", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_lesson_completion", x => x.Id);
                    table.ForeignKey(
                        name: "FK_lesson_completion_lesson_LessonId",
                        column: x => x.LessonId,
                        principalTable: "lesson",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_course_Slug",
                table: "course",
                column: "Slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_course_Status_Category_Level",
                table: "course",
                columns: new[] { "Status", "Category", "Level" });

            migrationBuilder.CreateIndex(
                name: "IX_enrollment_CourseId",
                table: "enrollment",
                column: "CourseId");

            migrationBuilder.CreateIndex(
                name: "IX_enrollment_UserId_CourseId",
                table: "enrollment",
                columns: new[] { "UserId", "CourseId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_CourseId_Idx",
                table: "lesson",
                columns: new[] { "CourseId", "Idx" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lesson_completion_LessonId",
                table: "lesson_completion",
                column: "LessonId");

            migrationBuilder.CreateIndex(
                name: "IX_lesson_completion_UserId_LessonId",
                table: "lesson_completion",
                columns: new[] { "UserId", "LessonId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "enrollment");

            migrationBuilder.DropTable(
                name: "lesson_completion");

            migrationBuilder.DropTable(
                name: "lesson");

            migrationBuilder.DropTable(
                name: "course");
        }
    }
}
