using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace auth_service.Migrations
{
    /// <inheritdoc />
    public partial class session : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "sessions",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "text", nullable: false),
                    DeviceId = table.Column<string>(type: "text", nullable: false),
                    Jti = table.Column<string>(type: "text", nullable: false),
                    Exp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastSeen = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Ua = table.Column<string>(type: "text", nullable: true),
                    Ip = table.Column<string>(type: "text", nullable: true),
                    PrevJti = table.Column<string>(type: "text", nullable: true),
                    RevokedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sessions", x => new { x.UserId, x.DeviceId });
                    table.ForeignKey(
                        name: "FK_sessions_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_sessions_DeviceId",
                table: "sessions",
                column: "DeviceId");

            migrationBuilder.CreateIndex(
                name: "IX_sessions_UserId",
                table: "sessions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_sessions_UserId_DeviceId",
                table: "sessions",
                columns: new[] { "UserId", "DeviceId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "sessions");
        }
    }
}
