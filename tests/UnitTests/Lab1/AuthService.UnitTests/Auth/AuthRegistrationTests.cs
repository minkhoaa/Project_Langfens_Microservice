namespace AuthService.UnitTests.Auth;

public class AuthRegistrationTests
{
    [Fact]
    public async Task RegisterAsync_Should_Fail_When_Email_Or_Password_Missing()
    {
        var builder = new AuthServiceTestBuilder();
        var service = builder.Build();
        var dto = new RegisterDto("   ", "");

        var result = await service.RegisterAsync(dto, CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.isSuccess.Should().BeFalse();
        builder.UserManager.Verify(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task RegisterAsync_Should_Fail_When_Email_Invalid()
    {
        var builder = new AuthServiceTestBuilder();
        builder.EmailValidator.Setup(v => v.IsValid("bad-email")).Returns(false);
        var service = builder.Build();
        var dto = new RegisterDto("bad-email", "Pass123!");

        var result = await service.RegisterAsync(dto, CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.message.Should().Contain("format");
        builder.UserManager.Verify(m => m.FindByEmailAsync(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task RegisterAsync_Should_Fail_When_Email_Already_Exists()
    {
        var builder = new AuthServiceTestBuilder();
        builder.EmailValidator.Setup(v => v.IsValid(It.IsAny<string>())).Returns(true);
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com" });
        var service = builder.Build();
        var dto = new RegisterDto("user@example.com", "Pass123!");

        var result = await service.RegisterAsync(dto, CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.message.Should().Contain("already");
        builder.UserManager.Verify(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task RegisterAsync_Should_Succeed_And_Send_Otp()
    {
        var builder = new AuthServiceTestBuilder();
        builder.EmailValidator.Setup(v => v.IsValid(It.IsAny<string>())).Returns(true);
        builder.UserManager
            .Setup(m => m.FindByEmailAsync(It.IsAny<string>()))
            .ReturnsAsync((User?)null);
        builder.UserManager
            .Setup(m => m.CreateAsync(It.IsAny<User>(), "Pass123!"))
            .ReturnsAsync(IdentityResult.Success);
        builder.OtpGenerator.Setup(g => g.Generate()).Returns("123456");
        var service = builder.Build();
        var dto = new RegisterDto("User@example.com", "Pass123!");

        var result = await service.RegisterAsync(dto, CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.isSuccess.Should().BeTrue();
        builder.OtpStore.Verify(s => s.PutOtp("user@example.com", "123456", It.IsAny<TimeSpan>()), Times.Once);
        builder.OtpStore.Verify(s => s.TouchResendCooldown("user@example.com", It.IsAny<TimeSpan>()), Times.Once);
        builder.PublishEndpoint.Verify(p =>
                p.Publish(
                    It.Is<UserRegisteredSendOtp>(msg =>
                        msg.Email == "user@example.com" && msg.Otp == "123456"),
                    It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task RegisterAsync_Should_Return_BadGateway_When_Otp_Publish_Fails()
    {
        var builder = new AuthServiceTestBuilder();
        builder.EmailValidator.Setup(v => v.IsValid(It.IsAny<string>())).Returns(true);
        builder.UserManager.Setup(m => m.FindByEmailAsync(It.IsAny<string>())).ReturnsAsync((User?)null);
        builder.UserManager.Setup(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Success);
        builder.OtpGenerator.Setup(g => g.Generate()).Returns("999999");
        builder.PublishEndpoint
            .Setup(p => p.Publish(It.IsAny<UserRegisteredSendOtp>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("smtp down"));
        var service = builder.Build();

        var result = await service.RegisterAsync(new RegisterDto("user@example.com", "Pass123!"),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status502BadGateway);
        result.Response.isSuccess.Should().BeFalse();
        result.Response.message.Should().Contain("Failed to send verification email");
    }
}
