using email_service.Features.Service;
using MassTransit;
using Shared.ExamDto.Contracts.Auth_Email;

namespace email_service.Features.Worker;

public sealed class UserRegisteredSendOtpConsumer(IEmailSender sender, ILogger<UserRegisteredSendOtpConsumer> logger) : IConsumer<UserRegisteredSendOtp>
{
    public async Task Consume(ConsumeContext<UserRegisteredSendOtp> context)
    {
        await sender.SendOtpAsync(context.Message.Email, context.Message.Otp, context.Message.TtlSeconds,
            context.CancellationToken);
        logger.LogInformation($"Email sent to {context.Message.Email}");
    }
}