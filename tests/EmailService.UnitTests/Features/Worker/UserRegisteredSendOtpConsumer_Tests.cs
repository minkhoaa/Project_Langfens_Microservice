
using System.Threading.Tasks;
using email_service.Features.Service;
using email_service.Features.Worker;
using FluentAssertions;
using MassTransit;
using MassTransit.Testing;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using Shared.ExamDto.Contracts.Auth_Email;
using Xunit;

namespace EmailService.UnitTests.Features.Worker;

public class UserRegisteredSendOtpConsumer_Tests
{
    public static IEnumerable<object[]> GetMessages()
    {
        for (int i = 1; i <= 11; i++)
        {
            yield return new object[] { $"user{i}@example.com", (100000 + i).ToString(), (long)(60 * i) };
        }
    }

    [Theory(DisplayName = "OE-005 Case {index}")]
    [MemberData(nameof(GetMessages))]
    public async Task Consumer_Should_Call_EmailSender_With_Payload(string email, string otp, long ttl)
    {
        // Arrange
        var mockEmailSender = new Mock<IEmailSender>();
        
        await using var provider = new ServiceCollection()
            .AddMassTransitTestHarness(cfg =>
            {
                cfg.AddConsumer<UserRegisteredSendOtpConsumer>();
            })
            .AddSingleton<IEmailSender>(mockEmailSender.Object)
            .BuildServiceProvider(true);

        var harness = provider.GetRequiredService<ITestHarness>();
        await harness.Start();

        var message = new UserRegisteredSendOtp(email, otp, ttl);

        // Act
        await harness.Bus.Publish(message);

        // Assert
        (await harness.Consumed.Any<UserRegisteredSendOtp>()).Should().BeTrue();
        
        var consumerHarness = harness.GetConsumerHarness<UserRegisteredSendOtpConsumer>();
        (await consumerHarness.Consumed.Any<UserRegisteredSendOtp>(
            x => x.Context.Message.Email == email && x.Context.Message.Otp == otp
            )).Should().BeTrue();

        mockEmailSender.Verify(sender => sender.SendOtpAsync(email, otp, ttl, It.IsAny<CancellationToken>()), Times.Once);
    }
    
    [Fact(DisplayName = "OE-005 Case12 - EmailSender Throws Exception")]
    public async Task Consumer_Should_Handle_EmailSender_Exception()
    {
        // Arrange
        var mockEmailSender = new Mock<IEmailSender>();
        var exception = new InvalidOperationException("Failed to send email");
        mockEmailSender
            .Setup(s => s.SendOtpAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<long>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(exception);
        
        await using var provider = new ServiceCollection()
            .AddMassTransitTestHarness(cfg =>
            {
                cfg.AddConsumer<UserRegisteredSendOtpConsumer>();
            })
            .AddSingleton<IEmailSender>(mockEmailSender.Object)
            .BuildServiceProvider(true);

        var harness = provider.GetRequiredService<ITestHarness>();
        await harness.Start();

        // Act
        // Publishing should not throw here; the fault is handled by MassTransit
        await harness.Bus.Publish(new UserRegisteredSendOtp("fault@example.com", "123", 60));

        // Assert
        // Verify the consumer was called
        (await harness.Consumed.Any<UserRegisteredSendOtp>()).Should().BeTrue();

        // Verify the mock was called
        mockEmailSender.Verify(sender => sender.SendOtpAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<long>(), It.IsAny<CancellationToken>()), Times.Once);
        
        // Check for the fault message
        (await harness.Published.Any<Fault<UserRegisteredSendOtp>>()).Should().BeTrue();
    }
}
