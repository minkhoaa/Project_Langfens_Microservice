using System.Text.Json;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Writing;
using writing_service.Contracts;
using writing_service.Domains.Entities;
using writing_service.Features.Helper;
using writing_service.Infrastructure.Persistence;

namespace writing_service.Features.RabbitMq
{
    public class WritingSubmittedConsumer : IConsumer<WritingGradeRequestMessage>
    {
        private readonly ILogger<WritingSubmittedConsumer> _logger;
        private readonly IWritingGrader _grader;
        private readonly IPublishEndpoint _bus;
        private readonly IAiCompareClient _compareClient;
        private readonly WritingDbContext _db;

        public WritingSubmittedConsumer(
            ILogger<WritingSubmittedConsumer> logger,
            IWritingGrader grader,
            IPublishEndpoint bus,
            IAiCompareClient compareClient,
            WritingDbContext db)
        {
            _grader = grader;
            _bus = bus;
            _logger = logger;
            _compareClient = compareClient;
            _db = db;
        }

        public async Task Consume(ConsumeContext<WritingGradeRequestMessage> context)
        {
            var request = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(request));
            var taskText = !string.IsNullOrEmpty(request.TaskText) ? request.TaskText : "";
            var answerText = !string.IsNullOrEmpty(request.AnswerText) ? request.AnswerText : "";

            // Branch on origin: Flow A pre-creates the row, Flow B does not.
            WritingEvaluation? evaluation;
            WritingGradeResponseDto response = new(); // placeholder, replaced in each branch

            if (request.SubmissionId.HasValue)
            {
                // Flow A: row exists; reuse band scores, do not re-grade.
                evaluation = await LoadEvaluationWithRetry(request.SubmissionId.Value, context.CancellationToken);
                if (evaluation is null)
                {
                    _logger.LogError(
                        "Flow A consumer could not find WritingEvaluation row for submission {Id} after retry; comparison skipped",
                        request.SubmissionId.Value);
                    return;
                }
                response = WritingGradeResponseDto.BuildResponseDtoFromEvaluation(evaluation);
            }
            else
            {
                // Flow B: create the row from message payload, then grade.
                var submission = new WritingSubmission
                {
                    UserId = request.UserId,
                    // Flow B essays come from exam-service questions, not writing-service
                    // WritingExams. ExamId is nullable in DB, so leave it NULL — setting
                    // a non-null value would violate the FK to writing_exams.
                    ExamId = null,
                    TaskTextSnapshot = taskText,
                    EssayRaw = answerText,
                    EssayNormalized = answerText,
                    // Defaults below mirror the entity defaults — Flow B doesn't have a
                    // WritingExam row to derive these from, so we accept the defaults.
                    WordCount = answerText.Split(new[] { ' ', '\n', '\t' }, StringSplitOptions.RemoveEmptyEntries).Length,
                    TimeSpentSeconds = null,
                    SubmittedAt = DateTime.UtcNow,
                };
                await _db.WritingSubmissions.AddAsync(submission, context.CancellationToken);

                var contentSubmission = new ContentSubmission { Task = taskText, Answer = answerText };
                var gradeResult = await _grader.GradeAsync(contentSubmission, context.CancellationToken);
                response = gradeResult.Response;
                var rawResponse = gradeResult.Compact;
                response.SubmissionId = submission.Id;

                evaluation = WritingEvaluationMapper.MapToEvaluation(response, rawResponse);
                _db.WritingEvaluations.Add(evaluation);
                await _db.SaveChangesAsync(context.CancellationToken);
            }

            _logger.LogInformation(JsonSerializer.Serialize(response));

            // Run comparison (same code path for both flows).
            var taskType = !string.IsNullOrEmpty(request.TaskType)
                ? request.TaskType
                : (taskText.Length > 300 ? "TASK_2" : "TASK_1");
            string? comparativeJson = null;
            try
            {
                var compareResult = await _compareClient.CompareAsync(
                    answerText, taskText, taskType, (float)response.OverallBand);
                if (compareResult != null)
                {
                    comparativeJson = JsonSerializer.Serialize(compareResult);
                    // Don't overwrite a comparison the FE has already received —
                    // a stale re-run would 204 the GET while the FE is still rendering.
                    if (string.IsNullOrEmpty(evaluation.ComparativeAnalysisJson))
                    {
                        evaluation.ComparativeAnalysisJson = comparativeJson;
                        await _db.SaveChangesAsync(context.CancellationToken);
                        _logger.LogInformation(
                            "Progressive comparison stored for submission {Id}", evaluation.SubmissionId);
                    }
                    else
                    {
                        _logger.LogInformation(
                            "Progressive comparison already present for submission {Id}; skipping overwrite",
                            evaluation.SubmissionId);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Progressive comparison failed (non-blocking)");
            }

            // Publish response ONLY for Flow B. Flow A has no PlacementResult to update;
            // the FE will read the comparison via /writing/{id}/comparison.
            if (!request.SubmissionId.HasValue)
            {
                var gradingResponse = new WritingGradeResponseMessage
                {
                    AttemptId = request.AttemptId,
                    UserId = request.UserId,
                    QuestionId = request.QuestionId,
                    TaskText = request.TaskText,
                    EssayRaw = response.EssayRaw,
                    EssayNormalized = response.EssayNormalized,
                    WordCount = response.WordCount,
                    OverallBand = response.OverallBand,
                    TaskResponse = response.TaskResponse.ToCriterionScore(),
                    CoherenceAndCohesion = response.CoherenceAndCohesion.ToCriterionScore(),
                    LexicalResource = response.LexicalResource.ToCriterionScore(),
                    GrammaticalRangeAndAccuracy = response.GrammaticalRangeAndAccuracy.ToCriterionScore(),
                    Suggestions = response.Suggestions,
                    ImprovedParagraph = response.ImprovedParagraph,
                    ComparativeAnalysisJson = comparativeJson
                };
                await _bus.Publish(gradingResponse);
            }
        }

        private async Task<WritingEvaluation?> LoadEvaluationWithRetry(Guid submissionId, CancellationToken ct)
        {
            // Exponential backoff: 200ms, 600ms, 1800ms (total max ~2.6s)
            int[] delaysMs = [200, 600, 1800];
            for (int attempt = 0; attempt <= delaysMs.Length; attempt++)
            {
                var evaluation = await _db.WritingEvaluations
                    .Where(e => e.SubmissionId == submissionId)
                    .OrderByDescending(e => e.CreatedAt)
                    .FirstOrDefaultAsync(ct);
                if (evaluation is not null) return evaluation;

                if (attempt < delaysMs.Length)
                    await Task.Delay(delaysMs[attempt], ct);
            }
            return null;
        }
    }
}
