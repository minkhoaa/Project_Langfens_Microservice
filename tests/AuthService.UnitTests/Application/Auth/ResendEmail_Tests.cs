extern alias authsvc;
using authsvc::auth_service.Application.Auth;
using authsvc::auth_service.Application.Common;
using authsvc::auth_service.Data;
using authsvc::auth_service.Infrastructure.Redis;
using authsvc::auth_service.Application.Common;
using FluentAssertions;
using MassTransit;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Time.Testing;
using Shared.ExamDto.Contracts;
using Shared.ExamDto.Contracts.Auth_Email;
using User = authsvc::auth_service.Infrastructure.Persistence.User;

namespace AuthService.UnitTests.Application.Auth
{
    public class ResendEmail_Tests
    {
        private readonly Mock<UserManager<User>> _mockUserManager;
        private readonly Mock<IOtpStore> _mockRedisOtpStore;
        private readonly Mock<IPublishEndpoint> _mockPublishEndpoint;
        private readonly Mock<IOtpGenerator> _mockOtpGenerator;
        private readonly FakeTimeProvider _fakeTimeProvider;
        private readonly authsvc::auth_service.Application.Auth.AuthService _sut;

        public ResendEmail_Tests()
        {
            var userStoreMock = new Mock<IUserStore<User>>();
            _mockUserManager = new Mock<UserManager<User>>(userStoreMock.Object, null, null, null, null, null, null, null, null);
            _mockRedisOtpStore = new Mock<IOtpStore>();
            _mockPublishEndpoint = new Mock<IPublishEndpoint>();
            _mockOtpGenerator = new Mock<IOtpGenerator>();
            _fakeTimeProvider = new FakeTimeProvider();
            var mockLogger = new Mock<ILogger<string>>();
            var jwtSettingsMock = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            jwtSettingsMock.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());

            _sut = new authsvc::auth_service.Application.Auth.AuthService(
                _mockUserManager.Object, null, null, null, null, null, null, null,
                _mockRedisOtpStore.Object, _mockPublishEndpoint.Object, Mock.Of<ILogger<string>>(), _mockOtpGenerator.Object, jwtSettingsMock.Object);
        }

        public static IEnumerable<object[]> ResendEmail_TestCases()
        {
            var userNotConfirmed = new User { Email = "test@example.com", EmailConfirmed = false };
            var userConfirmed = new User { Email = "confirmed@example.com", EmailConfirmed = true };
            yield return new object[] { "AU-004", "Case01_NullEmail", null, null, false, TimeSpan.Zero, 400, "Email is missing", false };
            yield return new object[] { "AU-004", "Case02_EmptyEmail", "", null, false, TimeSpan.Zero, 400, "Email is missing", false };
            yield return new object[] { "AU-004", "Case03_Whitespace", "  ", null, false, TimeSpan.Zero, 400, "Email is missing", false };
            yield return new object[] { "AU-004", "Case04_UserNotFound", "nonexistent@example.com", null, true, TimeSpan.Zero, 200, "Verification code was sent", false };
            yield return new object[] { "AU-004", "Case05_UserAlreadyConfirmed", userConfirmed.Email, userConfirmed, true, TimeSpan.Zero, 409, "Email is verified", false };
            yield return new object[] { "AU-004", "Case06_CooldownActive", userNotConfirmed.Email, userNotConfirmed, false, TimeSpan.FromSeconds(25), 400, "Please wait 25s", false };
            yield return new object[] { "AU-004", "Case07_HappyPath", userNotConfirmed.Email, userNotConfirmed, true, TimeSpan.Zero, 200, "Resend otp successfully", true };
            yield return new object[] { "AU-004", "Case08_EmailWithSpaces", "  test@example.com  ", userNotConfirmed, true, TimeSpan.Zero, 200, "Resend otp successfully", true };
            yield return new object[] { "AU-004", "Case09_EmailWithCasing", "Test@Example.Com", userNotConfirmed, true, TimeSpan.Zero, 200, "Resend otp successfully", true };
            yield return new object[] { "AU-004", "Case10_PublishThrows", userNotConfirmed.Email, userNotConfirmed, true, TimeSpan.Zero, 200, "Resend otp successfully", true, new Exception("RabbitMQ down") };
            yield return new object[] { "AU-004", "Case11_Cooldown_1s_Remaining", userNotConfirmed.Email, userNotConfirmed, false, TimeSpan.FromMilliseconds(800), 400, "Please wait 1s", false };
        }

        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(ResendEmail_TestCases))]
        public async Task ResendEmail_Should_Return_Correct_Result(
            string reqId, string caseId, string email, User user, bool canResend,
            TimeSpan remainingCooldown, int expectedStatusCode, string expectedMessage, bool verifyPublish, Exception publishException = null)
        {
            _ = reqId; _ = caseId;
            var trimmedEmail = email?.Trim().ToLowerInvariant();
            if (trimmedEmail is not null)
            {
                _mockUserManager.Setup(um => um.FindByEmailAsync(trimmedEmail)).ReturnsAsync(user);
                _mockRedisOtpStore.Setup(rs => rs.CanResend(trimmedEmail, It.IsAny<TimeSpan>())).ReturnsAsync(canResend);
                _mockRedisOtpStore.Setup(rs => rs.GetResendCooldownRemaining(trimmedEmail)).ReturnsAsync(remainingCooldown);
            }
            if (publishException != null)
            {
                _mockPublishEndpoint.Setup(p => p.Publish(It.IsAny<UserRegisteredSendOtp>(), It.IsAny<CancellationToken>())).ThrowsAsync(publishException);
            }
            var newOtp = "654321";
            _mockOtpGenerator.Setup(g => g.Generate()).Returns(newOtp);

            if (publishException != null)
            {
                Func<Task> act = async () => await _sut.ResendEmail(email, CancellationToken.None);
                await act.Should().ThrowAsync<Exception>().WithMessage(publishException.Message);
            }
            else
            {
                var result = await _sut.ResendEmail(email, CancellationToken.None);

                var objectResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
                objectResult.StatusCode.Should().Be(expectedStatusCode);

                if (objectResult.StatusCode is 200 or 400 or 409)
                {
                    var apiResult = objectResult.Should().BeAssignableTo<IValueHttpResult>().Subject.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
                    apiResult.message.Should().Contain(expectedMessage);
                    if (expectedStatusCode == 400 && remainingCooldown > TimeSpan.Zero)
                    {
                        var payload = apiResult.data.Should().NotBeNull().And.BeAssignableTo<object>().Subject;
                        var retryAfter = (int)payload.GetType().GetProperty("retryAfter")?.GetValue(payload, null);
                        retryAfter.Should().Be((int)Math.Ceiling(remainingCooldown.TotalSeconds));
                    }
                }
                if (verifyPublish)
                {
                    _mockPublishEndpoint.Verify(p => p.Publish(It.Is<UserRegisteredSendOtp>(m => m.Email == trimmedEmail && m.Otp == newOtp), It.IsAny<CancellationToken>()), Times.Once);
                    _mockRedisOtpStore.Verify(rs => rs.PutOtp(trimmedEmail, newOtp, It.IsAny<TimeSpan>()), Times.Once);
                    _mockRedisOtpStore.Verify(rs => rs.TouchResendCooldown(trimmedEmail, It.IsAny<TimeSpan>()), Times.Once);
                }
                else
                {
                    _mockPublishEndpoint.Verify(p => p.Publish(It.IsAny<object>(), It.IsAny<CancellationToken>()), Times.Never);
                }
            }
        }
    }
}
