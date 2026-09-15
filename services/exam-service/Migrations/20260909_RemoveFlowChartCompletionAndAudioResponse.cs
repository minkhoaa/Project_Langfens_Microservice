using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace exam_service.Migrations
{
    /// <inheritdoc />
    public partial class RemoveFlowChartCompletionAndAudioResponse : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Sprint 1 G1: enum cleanup. Two legacy QuestionType values were removed from
            // Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs:
            //   FLOW_CHART_COMPLETION  (folded into FLOW_CHART / SUMMARY_COMPLETION)
            //   AUDIO_RESPONSE         (folded into SHORT_ANSWER)
            //
            // QuestionGraderFactory.Resolve() throws NotSupportedException for unknown types
            // (verified QuestionGraderFactory.cs), so any historical row still carrying these
            // values would fail grading the moment an attempt loads the question.
            //
            // Map to the closest canonical replacement instead of deleting rows so question
            // history / audit trail stays intact. Idempotent — re-running on already-migrated
            // data is a no-op.
            migrationBuilder.Sql(@"
                UPDATE exam_questions
                SET ""Type"" = 'SUMMARY_COMPLETION'
                WHERE ""Type"" = 'FLOW_CHART_COMPLETION';

                UPDATE exam_questions
                SET ""Type"" = 'SHORT_ANSWER'
                WHERE ""Type"" = 'AUDIO_RESPONSE';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Cannot reverse: the two enum constants have been deleted from the C# source
            // (QuestionType.cs), so producing rows with those string values would put the
            // database out of sync with the code. Re-adding the constants + migrating the
            // rows back is a manual operation.
            migrationBuilder.Sql(@"
                -- Intentionally empty: legacy values FLOW_CHART_COMPLETION / AUDIO_RESPONSE
                -- have been removed from QuestionType.cs. A rollback must restore the enum
                -- constants before any data can be written back.
                SELECT 1;
            ");
        }
    }
}