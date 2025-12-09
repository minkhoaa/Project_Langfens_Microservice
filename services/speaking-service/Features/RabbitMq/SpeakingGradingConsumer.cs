using System.Net.WebSockets;
using System.Text.Json;
using MassTransit;
using Shared.ExamDto.Contracts.Speaking;

namespace speaking_service.Features.RabbitMq
{
    public class SpeakingGradingConsumer : IConsumer<SpeakingGradingRequestMessage>
    {
        private readonly ILogger<SpeakingGradingConsumer> _logger;
        private readonly IPublishEndpoint _bus;
        public SpeakingGradingConsumer(ILogger<SpeakingGradingConsumer> logger, IPublishEndpoint bus)
        {
            _logger = logger;
            _bus = bus;
        }
        public Task Consume(ConsumeContext<SpeakingGradingRequestMessage> context)
        {
            var res = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(res));
            return Task.CompletedTask;
        }
    }
}