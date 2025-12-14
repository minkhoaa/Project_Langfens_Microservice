using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using MassTransit;
using MassTransit.Testing;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using email_service.Features.Service;
using email_service.Features.Worker;
using Shared.ExamDto.Contracts.Auth_Email;
using Xunit;

namespace EmailService.UnitTests;

public class UserRegisteredSendOtpConsumerTests
{
    private readonly Faker _faker = new();

    [Fact]
    public async Task Consumer_Should_Call_EmailSender()
    {
        var emailSender = new Mock<IEmailSender>(MockBehavior.Strict);
        emailSender.Setup(s => s.SendOtpAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<long>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        await using var provider = new ServiceCollection()
            .AddMassTransitTestHarness(cfg =>
            {
                cfg.AddConsumer<UserRegisteredSendOtpConsumer>();
            })
            .AddScoped(_ => emailSender.Object)
            .BuildServiceProvider(true);

        var harness = provider.GetRequiredService<ITestHarness>();
        await harness.Start();

        var otp = _faker.Random.String2(6, "0123456789");
        await harness.Bus.Publish(new UserRegisteredSendOtp(_faker.Internet.Email(), otp, 60));

        (await harness.Consumed.Any<UserRegisteredSendOtp>()).Should().BeTrue();
        emailSender.Verify(s => s.SendOtpAsync(It.IsAny<string>(), otp, 60, It.IsAny<CancellationToken>()), Times.Once);
    }
}
