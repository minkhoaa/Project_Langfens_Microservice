using System.Text.Json;
using attempt_service.Features.Helpers;
using MassTransit;
using Shared.ExamDto.Contracts.Writing;

namespace attempt_service.Features.RabbitMq
{
    public class WritingGradedConsumer : IConsumer<WritingGradeResponseMessage>
    {
        private readonly ILogger<WritingGradedConsumer> _logger;
        private readonly IPlacementWorkflow _placementWorkflow;
        public WritingGradedConsumer(ILogger<WritingGradedConsumer> logger, IPlacementWorkflow placementWorkflow)
        {
            _logger = logger;
            _placementWorkflow = placementWorkflow;
        }
        public async Task Consume(ConsumeContext<WritingGradeResponseMessage> context)
        {
            var res = context.Message;
            _logger.LogInformation(JsonSerializer.Serialize(res));
            await _placementWorkflow.OnWritingGradedAsync(res, CancellationToken.None);
        }
    }
}
