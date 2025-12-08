using System.Text.Json;
using MassTransit;
using Shared.ExamDto.Contracts.Speaking;

namespace attempt_service.Features.RabbitMq
{
    public class SpeakingGradedConsumer : IConsumer<SpeakingGradingResponseMessage>
    {
        private readonly ILogger<SpeakingGradedConsumer> _logger;
        public SpeakingGradedConsumer(ILogger<SpeakingGradedConsumer> logger)
        {
            _logger = logger;
        }
        public Task Consume(ConsumeContext<SpeakingGradingResponseMessage> context)
        {
            _logger.LogInformation(JsonSerializer.Serialize(context.Message));
            return Task.CompletedTask;
        }
    }
}