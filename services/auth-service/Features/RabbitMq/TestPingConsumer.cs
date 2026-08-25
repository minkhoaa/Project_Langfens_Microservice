using MassTransit;
using Shared.ExamDto.Contracts.Auth_Email;

namespace auth_service.Features.RabbitMq;

public sealed class TestpingConsumer(ILogger<TestpingConsumer> log) : IConsumer<TestPing>
{
    public Task Consume(ConsumeContext<TestPing> context)
    {
        log.LogInformation("✅ TestPing received: {Text} @ {At}", context.Message.Text, context.Message.At);
        Console.WriteLine("auth service received");
        return Task.CompletedTask;
    }
}
