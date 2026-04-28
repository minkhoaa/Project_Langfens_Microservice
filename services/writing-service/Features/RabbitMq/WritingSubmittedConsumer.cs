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
            WritingGradeResponse response;

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
                response = BuildResponseFromEvaluation(evaluation);
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
                var graded = await _grader.Grade(contentSubmission, context.CancellationToken);
                response = graded.Item1;
                var rawResponse = graded.Item2;
                response.SubmissionId = submission.Id;

                evaluation = _grader.MapToEvaluation(response, rawResponse);
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
                    evaluation.ComparativeAnalysisJson = comparativeJson;
                    await _db.SaveChangesAsync(context.CancellationToken);
                    _logger.LogInformation(
                        "Progressive comparison stored for submission {Id}", evaluation.SubmissionId);
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
                    TaskResponse = response.TaskResponse,
                    CoherenceAndCohesion = response.CoherenceAndCohesion,
                    LexicalResource = response.LexicalResource,
                    GrammaticalRangeAndAccuracy = response.GrammaticalRangeAndAccuracy,
                    Suggestions = response.Suggestions,
                    ImprovedParagraph = response.ImprovedParagraph,
                    ComparativeAnalysisJson = comparativeJson
                };
                await _bus.Publish(gradingResponse);
            }
        }

        private async Task<WritingEvaluation?> LoadEvaluationWithRetry(Guid submissionId, CancellationToken ct)
        {
            // Race: sync handler may not have committed before this consumer reads.
            // Retry once after 500ms to absorb the typical race window.
            var evaluation = await _db.WritingEvaluations
                .Where(e => e.SubmissionId == submissionId)
                .OrderByDescending(e => e.CreatedAt)
                .FirstOrDefaultAsync(ct);
            if (evaluation is not null) return evaluation;

            await Task.Delay(500, ct);
            return await _db.WritingEvaluations
                .Where(e => e.SubmissionId == submissionId)
                .OrderByDescending(e => e.CreatedAt)
                .FirstOrDefaultAsync(ct);
        }

        private static WritingGradeResponse BuildResponseFromEvaluation(WritingEvaluation eval)
        {
            var suggestions = new List<string>();
            if (!string.IsNullOrWhiteSpace(eval.SuggestionsJson))
            {
                try
                {
                    suggestions = JsonSerializer.Deserialize<List<string>>(eval.SuggestionsJson)
                        ?? new List<string>();
                }
                catch (JsonException) { /* keep empty */ }
            }
            return new WritingGradeResponse
            {
                SubmissionId = eval.SubmissionId,
                EssayRaw = string.Empty,
                EssayNormalized = string.Empty,
                WordCount = 0,
                OverallBand = eval.OverallBand,
                TaskResponse = new CriterionScore { Band = eval.TaskResponseBand, Comment = eval.TaskResponseComment },
                CoherenceAndCohesion = new CriterionScore { Band = eval.CoherenceAndCohesionBand, Comment = eval.CoherenceAndCohesionComment },
                LexicalResource = new CriterionScore { Band = eval.LexicalResourceBand, Comment = eval.LexicalResourceComment },
                GrammaticalRangeAndAccuracy = new CriterionScore { Band = eval.GrammaticalRangeAndAccuracyBand, Comment = eval.GrammaticalRangeAndAccuracyComment },
                Suggestions = suggestions,
                ImprovedParagraph = eval.ImprovedParagraph ?? string.Empty,
                Model = eval.Model,
                ModelProvider = eval.Provider,
                GradedAt = eval.CreatedAt,
                RawLlmJson = eval.RawLlmJson
            };
        }
    }
}
