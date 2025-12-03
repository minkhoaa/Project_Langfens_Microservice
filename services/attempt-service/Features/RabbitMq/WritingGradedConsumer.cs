using System.Text.Json;
using MassTransit;
using Shared.ExamDto.Contracts.Writing;

namespace attempt_service.Features.RabbitMq
{
    public class WritingGradedConsumer : IConsumer<WritingGradeResponseMessage>
    {
        private readonly ILogger<WritingGradedConsumer> _logger;
        public WritingGradedConsumer(ILogger<WritingGradedConsumer> logger)
        {
            _logger = logger;
        }
        public Task Consume(ConsumeContext<WritingGradeResponseMessage> context)
        {
            var res = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(res));

            return Task.CompletedTask;
        }
    }
}
