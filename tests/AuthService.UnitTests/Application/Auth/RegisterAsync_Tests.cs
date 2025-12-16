extern alias authsvc;
using authsvc::auth_service.Application.Auth;
using authsvc::auth_service.Application.Common;
using authsvc::auth_service.Data;
using authsvc::auth_service.Infrastructure.Redis;
using AuthService.UnitTests.Common.Builders.Auth;
using FluentAssertions;
using MassTransit;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Shared.ExamDto.Contracts.Auth_Email;
using Shared.Security.Roles;
using Xunit;
using Microsoft.Extensions.Options;
using User = authsvc::auth_service.Infrastructure.Persistence.User;
using Role = authsvc::auth_service.Infrastructure.Persistence.Role;

namespace AuthService.UnitTests.Application.Auth
{
    public class RegisterAsync_Tests
    {
        private readonly Mock<UserManager<User>> _mockUserManager;
        private readonly Mock<RoleManager<Role>> _mockRoleManager;
        private readonly Mock<IEmailValidator> _mockEmailValidator;
        private readonly Mock<IOtpStore> _mockRedisOtpStore;
        private readonly Mock<IPublishEndpoint> _mockPublishEndpoint;
        private readonly Mock<IOtpGenerator> _mockOtpGenerator;
        private readonly Mock<ILogger<string>> _mockLogger;
        private readonly Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>> _mockJwtSettings;
        private readonly authsvc::auth_service.Application.Auth.AuthService _sut;

        public RegisterAsync_Tests()
        {
            var userStoreMock = new Mock<IUserStore<User>>();
            _mockUserManager = new Mock<UserManager<User>>(userStoreMock.Object, null, null, null, null, null, null, null, null);
            var roleStoreMock = new Mock<IRoleStore<Role>>();
            _mockRoleManager = new Mock<RoleManager<Role>>(roleStoreMock.Object, null, null, null, null);
            _mockEmailValidator = new Mock<IEmailValidator>();
            _mockRedisOtpStore = new Mock<IOtpStore>();
            _mockPublishEndpoint = new Mock<IPublishEndpoint>();
            _mockOtpGenerator = new Mock<IOtpGenerator>();
            _mockLogger = new Mock<ILogger<string>>();
            _mockJwtSettings = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            _mockJwtSettings.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());
            _mockOtpGenerator.Setup(x => x.Generate()).Returns("123456");

            _sut = new authsvc::auth_service.Application.Auth.AuthService(
                _mockUserManager.Object, _mockRoleManager.Object, null, null,
                _mockEmailValidator.Object, null, null, null,
                _mockRedisOtpStore.Object, _mockPublishEndpoint.Object, _mockLogger.Object, _mockOtpGenerator.Object, _mockJwtSettings.Object);
        }

        public static IEnumerable<object[]> RegisterAsync_TestCases()
        {
            yield return new object[] { "AU-001", "Case01", new RegisterDtoBuilder().WithEmail(null).Build(), "Email or password is missed", 400, null, IdentityResult.Success, false };
            yield return new object[] { "AU-001", "Case02", new RegisterDtoBuilder().WithEmail(" ").Build(), "Email or password is missed", 400, null, IdentityResult.Success, false };
            yield return new object[] { "AU-001", "Case03", new RegisterDtoBuilder().WithPassword(null).Build(), "Email or password is missed", 400, null, IdentityResult.Success, false };
            yield return new object[] { "AU-001", "Case04", new RegisterDtoBuilder().WithPassword(" ").Build(), "Email or password is missed", 400, null, IdentityResult.Success, false };
            yield return new object[] { "AU-001", "Case05", new RegisterDtoBuilder().WithEmail("invalid-email").Build(), "Email format is not valid", 400, null, IdentityResult.Success, false };
            yield return new object[] { "AU-002", "Case06", new RegisterDtoBuilder().Build(), "Email is already used", 400, new User(), IdentityResult.Success, true };
            yield return new object[] { "AU-001", "Case07", new RegisterDtoBuilder().Build(), "Password is too short", 400, null, IdentityResult.Failed(new IdentityError { Description = "Password is too short" }), true };
            yield return new object[] { "AU-003", "Case08", new RegisterDtoBuilder().Build(), "User is created successfully", 200, null, IdentityResult.Success, true };
            yield return new object[] { "AU-003", "Case09", new RegisterDtoBuilder().Build(), "User is created successfully", 200, null, IdentityResult.Success, true, false, IdentityResult.Failed() };
            yield return new object[] { "AU-003", "Case10", new RegisterDtoBuilder().Build(), "User is created successfully", 200, null, IdentityResult.Success, true, true, IdentityResult.Failed() };
            yield return new object[] { "AU-003", "Case11", new RegisterDtoBuilder().Build(), "Failed to send verification email", 502, null, IdentityResult.Success, true, true, IdentityResult.Success, IdentityResult.Success, new Exception("RabbitMQ is down") };
        }

        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(RegisterAsync_TestCases))]
        public async Task RegisterAsync_Should_Handle_Various_Scenarios(
            string reqId, string caseId, RegisterDto dto, string expectedMessage, int expectedStatusCode,
            User existingUser, IdentityResult userManagerResult, bool isEmailValid,
            bool roleExists = true, IdentityResult createRoleResult = null, IdentityResult addToRoleResult = null, Exception publishException = null)
        {
            _ = reqId; _ = caseId;
            // Arrange
            _mockEmailValidator.Setup(v => v.IsValid(It.IsAny<string>())).Returns(isEmailValid);
            if (dto.Email is not null)
            {
                _mockUserManager.Setup(um => um.FindByEmailAsync(dto.Email.Trim().ToLowerInvariant())).ReturnsAsync(existingUser);
            }
            if (userManagerResult != null)
            {
                _mockUserManager.Setup(um => um.CreateAsync(It.IsAny<User>(), It.IsAny<string>())).ReturnsAsync(userManagerResult);
            }
            _mockRoleManager.Setup(rm => rm.RoleExistsAsync(Roles.User)).ReturnsAsync(roleExists);
            if (createRoleResult != null)
            {
                _mockRoleManager.Setup(rm => rm.CreateAsync(It.IsAny<Role>())).ReturnsAsync(createRoleResult);
            }
            if (addToRoleResult != null)
            {
                _mockUserManager.Setup(um => um.AddToRoleAsync(It.IsAny<User>(), Roles.User)).ReturnsAsync(addToRoleResult);
            }
            if (publishException != null)
            {
                _mockPublishEndpoint.Setup(p => p.Publish(It.IsAny<UserRegisteredSendOtp>(), It.IsAny<CancellationToken>())).ThrowsAsync(publishException);
            }
            if (publishException != null)
            {
                Func<Task> act = async () => await _sut.RegisterAsync(dto, CancellationToken.None);
                await act.Should().ThrowAsync<Exception>().WithMessage(publishException.Message);
            }
            else
            {
                var result = await _sut.RegisterAsync(dto, CancellationToken.None);
                result.StatusCode.Should().Be(expectedStatusCode);

                if (result.StatusCode == 200)
                {
                    result.Response.isSuccess.Should().BeTrue();
                    _mockUserManager.Verify(um => um.CreateAsync(It.Is<User>(u => u.Email == dto.Email.ToLowerInvariant()), dto.Password), Times.Once);
                }
                else 
                {
                     if (result.Response != null) 
                     {
                        result.Response.message.Should().Contain(expectedMessage);
                     }
                }
            }
        }
    }
}