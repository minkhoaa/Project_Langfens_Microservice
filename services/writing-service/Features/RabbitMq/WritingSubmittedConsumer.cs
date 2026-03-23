using System.Text.Json;
using MassTransit;
using Microsoft.EntityFrameworkCore;
using Shared.ExamDto.Contracts.Writing;
using writing_service.Contracts;
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

            var contentSubmission = new ContentSubmission() { Task = taskText, Answer = answerText };
            var (response, rawResponse) = await _grader.Grade(contentSubmission, context.CancellationToken);
            _logger.LogInformation(JsonSerializer.Serialize(response));

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
                ImprovedParagraph = response.ImprovedParagraph
            };

            // Run comparison BEFORE publishing (so response includes comparative data)
            var taskType = taskText.Length > 300 ? "TASK_2" : "TASK_1";
            try
            {
                var compareResult = await _compareClient.CompareAsync(
                    answerText, taskText, taskType, (float)response.OverallBand);
                if (compareResult != null)
                {
                    gradingResponse.ComparativeAnalysisJson = JsonSerializer.Serialize(compareResult);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Progressive comparison failed (non-blocking)");
            }

            _logger.LogInformation(JsonSerializer.Serialize(response));
            await _bus.Publish(gradingResponse);

            // Fire-and-forget: update WritingEvaluation record (for durability)
            _ = UpdateEvaluationRecordAsync(request, response, gradingResponse.ComparativeAnalysisJson);
        }

        private async Task UpdateEvaluationRecordAsync(
            WritingGradeRequestMessage request,
            WritingGradeResponse response,
            string? comparativeAnalysisJson)
        {
            try
            {
                if (string.IsNullOrEmpty(comparativeAnalysisJson)) return;

                var evaluation = await _db.WritingEvaluations
                    .Where(e => e.SubmissionId == request.QuestionId)
                    .OrderByDescending(e => e.CreatedAt)
                    .FirstOrDefaultAsync();

                if (evaluation != null)
                {
                    evaluation.ComparativeAnalysisJson = comparativeAnalysisJson;
                    await _db.SaveChangesAsync();
                    _logger.LogInformation(
                        "Progressive comparison stored for submission {Id}", evaluation.SubmissionId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to update evaluation record (non-blocking)");
            }
        }
    }
}
