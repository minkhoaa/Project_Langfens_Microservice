using System.Text.Json;
using attempt_service.Features.Helpers;
using MassTransit;
using Shared.ExamDto.Contracts.Speaking;

namespace attempt_service.Features.RabbitMq
{
    public class SpeakingGradedConsumer : IConsumer<SpeakingGradingResponseMessage>
    {
        private readonly ILogger<SpeakingGradedConsumer> _logger;
        private readonly IPlacementWorkflow _placementWorkflow;
        public SpeakingGradedConsumer(ILogger<SpeakingGradedConsumer> logger, IPlacementWorkflow placementWorkflow)
        {
            _logger = logger;
            _placementWorkflow = placementWorkflow;
        }
        public async Task Consume(ConsumeContext<SpeakingGradingResponseMessage> context)
        {
            var request = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(request));

            await _placementWorkflow.OnSpeakingGradedAsync(request, CancellationToken.None);

        }
    }
}