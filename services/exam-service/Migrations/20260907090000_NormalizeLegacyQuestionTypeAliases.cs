using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class NormalizeLegacyQuestionTypeAliases : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Normalize legacy short aliases to canonical QuestionType constants consumed by attempt-service.
            // Idempotent: only rewrites rows that still hold the legacy values, so re-running is safe.
            migrationBuilder.Sql(@"
                UPDATE exam_questions
                SET ""Type"" = 'MULTIPLE_CHOICE_SINGLE'
                WHERE ""Type"" = 'MCQ_SINGLE';

                UPDATE exam_questions
                SET ""Type"" = 'MULTIPLE_CHOICE_MULTIPLE'
                WHERE ""Type"" = 'MCQ_MULTIPLE';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Reverse the rename so a rollback restores the legacy alias.
            migrationBuilder.Sql(@"
                UPDATE exam_questions
                SET ""Type"" = 'MCQ_SINGLE'
                WHERE ""Type"" = 'MULTIPLE_CHOICE_SINGLE';

                UPDATE exam_questions
                SET ""Type"" = 'MCQ_MULTIPLE'
                WHERE ""Type"" = 'MULTIPLE_CHOICE_MULTIPLE';
            ");
        }
    }
}