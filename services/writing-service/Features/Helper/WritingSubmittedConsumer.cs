using System.Text.Json;
using MassTransit;
using Shared.ExamDto.Contracts.Writing;

namespace writing_service.Features.Helper
{
    public class WritingSubmittedConsumer(ILogger<WritingSubmittedConsumer> logger) : IConsumer<WritingGradeRequestMessage>
    {

        public Task Consume(ConsumeContext<WritingGradeRequestMessage> context)
        {
            var res = context.Message;
            logger.LogInformation(JsonSerializer.Serialize(res));
            return Task.CompletedTask;
        }
    }
}