using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace attempt_service.Migrations
{
    /// <inheritdoc />
    public partial class AddStudyGoal : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "study_goals",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    TargetBandScore = table.Column<decimal>(type: "numeric(3,1)", precision: 3, scale: 1, nullable: false),
                    TargetDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    FocusSkills = table.Column<List<string>>(type: "text[]", nullable: false),
                    StudyHoursPerDay = table.Column<decimal>(type: "numeric(3,1)", precision: 3, scale: 1, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_study_goals", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "idx_study_goal_user",
                table: "study_goals",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "study_goals");
        }
    }
}
