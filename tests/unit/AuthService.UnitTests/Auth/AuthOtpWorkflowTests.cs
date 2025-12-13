namespace AuthService.UnitTests.Auth;

public class AuthOtpWorkflowTests
{
    [Fact]
    public async Task ResendEmail_Should_Return_BadRequest_When_Cooldown_Active()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com", EmailConfirmed = false });
        builder.OtpStore.Setup(s => s.CanResend("user@example.com", It.IsAny<TimeSpan>())).ReturnsAsync(false);
        builder.OtpStore.Setup(s => s.GetResendCooldownRemaining("user@example.com"))
            .ReturnsAsync(TimeSpan.FromSeconds(42));
        var service = builder.Build();

        var (status, payload) =
            ResultAssert.Api(await service.ResendEmail("user@example.com", CancellationToken.None));

        status.Should().Be(StatusCodes.Status400BadRequest);
        payload.message.Should().Contain("Please wait 42s");
        payload.data.Should().BeEquivalentTo(new { retryAfter = 42 });
        builder.PublishEndpoint.Verify(p => p.Publish(It.IsAny<UserRegisteredSendOtp>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task ResendEmail_Should_Send_New_Otp_When_Allowed()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com", EmailConfirmed = false });
        builder.OtpStore.Setup(s => s.CanResend("user@example.com", It.IsAny<TimeSpan>())).ReturnsAsync(true);
        builder.OtpGenerator.Setup(g => g.Generate()).Returns("654321");
        var service = builder.Build();

        var (status, payload) =
            ResultAssert.Api(await service.ResendEmail("user@example.com", CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        builder.OtpStore.Verify(s => s.PutOtp("user@example.com", "654321", It.IsAny<TimeSpan>()), Times.Once);
        builder.PublishEndpoint.Verify(p =>
                p.Publish(
                    It.Is<UserRegisteredSendOtp>(msg => msg.Email == "user@example.com" && msg.Otp == "654321"),
                    It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ForgotPasswordRequest_Should_Throttle_When_Cooldown_Active()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com", EmailConfirmed = true });
        builder.OtpStore.Setup(s => s.CanResend("pwreset::user@example.com", It.IsAny<TimeSpan>()))
            .ReturnsAsync(false);
        var service = builder.Build();

        var (status, payload) =
            ResultAssert.Api(await service.ForgotPasswordRequestAsync("user@example.com", CancellationToken.None));

        status.Should().Be(StatusCodes.Status400BadRequest);
        payload.message.Should().Contain("Too many requests");
        builder.OtpStore.Verify(s => s.PutOtp(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<TimeSpan>()), Times.Never);
    }

    [Fact]
    public async Task ForgotPasswordRequest_Should_Send_Otp_When_Allowed()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com", EmailConfirmed = true });
        builder.OtpStore.Setup(s => s.CanResend("pwreset::user@example.com", It.IsAny<TimeSpan>()))
            .ReturnsAsync(true);
        builder.OtpGenerator.Setup(g => g.Generate()).Returns("135790");
        var service = builder.Build();

        var (status, payload) =
            ResultAssert.Api(await service.ForgotPasswordRequestAsync("user@example.com", CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.message.Should().Contain("reset instructions");
        builder.OtpStore.Verify(s =>
                s.PutOtp("pwreset::user@example.com", "135790", It.IsAny<TimeSpan>()),
            Times.Once);
        builder.PublishEndpoint.Verify(p =>
                p.Publish(
                    It.Is<UserRegisteredSendOtp>(msg =>
                        msg.Email == "user@example.com" && msg.Otp == "135790"),
                    It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ConfirmResetPassword_Should_Succeed_When_Otp_Valid()
    {
        var builder = new AuthServiceTestBuilder();
        var user = new User { Email = "user@example.com" };
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com")).ReturnsAsync(user);
        builder.OtpStore.Setup(s => s.Verify("pwreset::user@example.com", "000888", It.IsAny<int>(), It.IsAny<TimeSpan>()))
            .ReturnsAsync(true);
        builder.UserManager.Setup(m => m.GeneratePasswordResetTokenAsync(user))
            .ReturnsAsync("token");
        builder.UserManager.Setup(m => m.ResetPasswordAsync(user, "token", "NewPassword1!"))
            .ReturnsAsync(IdentityResult.Success);
        var service = builder.Build();

        var (status, payload) = ResultAssert.Api(
            await service.ConfirmResetPasswordAsync("user@example.com", "000888", "NewPassword1!", CancellationToken.None));

        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        builder.OtpStore.Verify(s => s.Clear("pwreset::user@example.com"), Times.Once);
    }

    [Fact]
    public async Task ConfirmResetPassword_Should_Fail_When_Otp_Invalid()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Email = "user@example.com" });
        builder.OtpStore.Setup(s => s.Verify("pwreset::user@example.com", "123123", It.IsAny<int>(), It.IsAny<TimeSpan>()))
            .ReturnsAsync(false);
        var service = builder.Build();

        var (status, payload) = ResultAssert.Api(
            await service.ConfirmResetPasswordAsync("user@example.com", "123123", "NewPassword1!", CancellationToken.None));

        status.Should().Be(StatusCodes.Status400BadRequest);
        payload.message.Should().Contain("invalid or expired");
        builder.UserManager.Verify(m => m.ResetPasswordAsync(It.IsAny<User>(), It.IsAny<string>(), It.IsAny<string>()),
            Times.Never);
    }
}
