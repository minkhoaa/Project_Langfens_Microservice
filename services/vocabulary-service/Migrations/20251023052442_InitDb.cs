using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace vocabulary_service.Migrations
{
    /// <inheritdoc />
    public partial class InitDb : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "deck",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Slug = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    DescriptionMd = table.Column<string>(type: "text", nullable: true),
                    Category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_deck", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "card",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DeckId = table.Column<Guid>(type: "uuid", nullable: false),
                    Idx = table.Column<int>(type: "integer", nullable: false),
                    FrontMd = table.Column<string>(type: "text", nullable: false),
                    BackMd = table.Column<string>(type: "text", nullable: false),
                    HintMd = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_card", x => x.Id);
                    table.ForeignKey(
                        name: "FK_card_deck_DeckId",
                        column: x => x.DeckId,
                        principalTable: "deck",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_deck",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    DeckId = table.Column<Guid>(type: "uuid", nullable: false),
                    Status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    SubscribeAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_deck", x => x.Id);
                    table.ForeignKey(
                        name: "FK_user_deck_deck_DeckId",
                        column: x => x.DeckId,
                        principalTable: "deck",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "review_log",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    CardId = table.Column<Guid>(type: "uuid", nullable: false),
                    Grade = table.Column<int>(type: "integer", nullable: false),
                    ReviewedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    EaseFactor = table.Column<double>(type: "double precision", nullable: false),
                    IntervalDays = table.Column<int>(type: "integer", nullable: false),
                    Repetition = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_review_log", x => x.Id);
                    table.ForeignKey(
                        name: "FK_review_log_card_CardId",
                        column: x => x.CardId,
                        principalTable: "card",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_card_review_state",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    CardId = table.Column<Guid>(type: "uuid", nullable: false),
                    Repetition = table.Column<int>(type: "integer", nullable: false),
                    EaseFactor = table.Column<double>(type: "double precision", nullable: false),
                    IntervalDays = table.Column<int>(type: "integer", nullable: false),
                    DueAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    LastReviewedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    TotalReviews = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_card_review_state", x => x.Id);
                    table.ForeignKey(
                        name: "FK_user_card_review_state_card_CardId",
                        column: x => x.CardId,
                        principalTable: "card",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_card_DeckId_Idx",
                table: "card",
                columns: new[] { "DeckId", "Idx" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_deck_Slug",
                table: "deck",
                column: "Slug");

            migrationBuilder.CreateIndex(
                name: "IX_deck_Status_Category",
                table: "deck",
                columns: new[] { "Status", "Category" });

            migrationBuilder.CreateIndex(
                name: "IX_review_log_CardId",
                table: "review_log",
                column: "CardId");

            migrationBuilder.CreateIndex(
                name: "IX_review_log_UserId_CardId_ReviewedAt",
                table: "review_log",
                columns: new[] { "UserId", "CardId", "ReviewedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_user_card_review_state_CardId",
                table: "user_card_review_state",
                column: "CardId");

            migrationBuilder.CreateIndex(
                name: "IX_user_card_review_state_DueAt",
                table: "user_card_review_state",
                column: "DueAt");

            migrationBuilder.CreateIndex(
                name: "IX_user_card_review_state_UserId_CardId",
                table: "user_card_review_state",
                columns: new[] { "UserId", "CardId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_user_deck_DeckId_Status",
                table: "user_deck",
                columns: new[] { "DeckId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_user_deck_UserId_DeckId",
                table: "user_deck",
                columns: new[] { "UserId", "DeckId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "review_log");

            migrationBuilder.DropTable(
                name: "user_card_review_state");

            migrationBuilder.DropTable(
                name: "user_deck");

            migrationBuilder.DropTable(
                name: "card");

            migrationBuilder.DropTable(
                name: "deck");
        }
    }
}
