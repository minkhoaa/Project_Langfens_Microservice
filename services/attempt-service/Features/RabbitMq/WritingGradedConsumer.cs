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
        public WritingGradedConsumer(ILogger<WritingGradedConsumer> logger, IPlacementWorkflow placemenWorkflow)
        {
            _logger = logger;
            _placementWorkflow = placemenWorkflow;
        }
        public async Task Consume(ConsumeContext<WritingGradeResponseMessage> context)
        {
            var res = context.Message;
            await _placementWorkflow.OnWritingGradedAsync(res, CancellationToken.None);
            _logger.LogInformation("Placement writing graded for attempt {AttemptId} with payload:\n", context.Message);
        }
    }
}
