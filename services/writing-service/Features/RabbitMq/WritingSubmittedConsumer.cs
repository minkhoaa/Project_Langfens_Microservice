using System.Text.Json;
using MassTransit;
using Shared.ExamDto.Contracts.Writing;
using writing_service.Contracts;
using writing_service.Features.Helper;

namespace writing_service.Features.RabbitMq
{
    public class WritingSubmittedConsumer : IConsumer<WritingGradeRequestMessage>
    {
        private readonly ILogger<WritingSubmittedConsumer> _logger;
        private readonly IWritingGrader _grader;
        private readonly IPublishEndpoint _bus;
        public WritingSubmittedConsumer(
            ILogger<WritingSubmittedConsumer> logger,
            IWritingGrader grader,
            IPublishEndpoint bus

            )
        {
            _grader = grader;
            _bus = bus;
            _logger = logger;
        }
        public async Task Consume(ConsumeContext<WritingGradeRequestMessage> context)
        {
            var request = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(request));
            var taskText = !string.IsNullOrEmpty(request.TaskText) ? request.TaskText : "";
            var answerText = !string.IsNullOrEmpty(request.AnswerText) ? request.AnswerText : "";

            var contentSubmission = new ContentSubmission() { Task = taskText, Answer = answerText };
            var (response, rawResponse) = await _grader.Grade(contentSubmission, CancellationToken.None);
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
            _logger.LogInformation(JsonSerializer.Serialize(response));
            await _bus.Publish(gradingResponse);
        }
    }
}