using System.Text.Json;
using attempt_service.Features.Helpers;
using MassTransit;
using Shared.ExamDto.Contracts.Writing;

namespace attempt_service.Features.RabbitMq
{
    public class WritingGradedConsumer : IConsumer<WritingGradeResponseMessage>
    {
        private readonly ILogger<WritingGradedConsumer> _logger;
        private readonly IPlacementWorkflow _writingWorkflow;
        public WritingGradedConsumer(ILogger<WritingGradedConsumer> logger, IPlacementWorkflow writingWorkflow)
        {
            _logger = logger;
            _writingWorkflow = writingWorkflow;
        }
        public async Task Consume(ConsumeContext<WritingGradeResponseMessage> context)
        {
            var res = context.Message;
            await _writingWorkflow.OnWritingGradedAsync(res, CancellationToken.None);
            _logger.LogInformation(JsonSerializer.Serialize(res));
        }
    }
}
