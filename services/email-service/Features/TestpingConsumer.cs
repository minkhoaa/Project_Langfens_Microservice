using MassTransit;
using Shared.ExamDto.Contracts.Auth_Email;

namespace email_service.Features;

public sealed class TestpingConsumer(ILogger<TestpingConsumer> log) : IConsumer<TestPing>
{
    public Task Consume(ConsumeContext<TestPing> context)
    {
        log.LogInformation("✅ TestPing received: {Text} @ {At}", context.Message.Text, context.Message.At);
        Console.WriteLine("email service received");
        return Task.CompletedTask;
    }
}
