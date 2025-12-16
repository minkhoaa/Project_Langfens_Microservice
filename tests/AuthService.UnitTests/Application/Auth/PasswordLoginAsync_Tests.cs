extern alias authsvc;
using System.Security.Claims;
using authsvc::auth_service.Application.Auth;
using authsvc::auth_service.Application.Common;
using authsvc::auth_service.Data;
using authsvc::auth_service.Infrastructure.Persistence;
using authsvc::auth_service.Infrastructure.Redis;
using AuthService.UnitTests.Common.Builders.Auth;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Shared.ExamDto.Contracts;
using Shared.Security.Claims;
using Shared.Security.Roles;
using Xunit;

namespace AuthService.UnitTests.Application.Auth
{
    public class PasswordLoginAsync_Tests
    {
        private readonly Mock<UserManager<User>> _mockUserManager;
        private readonly Mock<SignInManager<User>> _mockSignInManager;
        private readonly Mock<IJwtTokenFactory> _mockJwtTokenFactory;
        private readonly Mock<ISessionRepository> _mockSessionRepository;
        private readonly Mock<ISessionStore> _mockSessionStore;
        private readonly authsvc::auth_service.Application.Auth.AuthService _sut;

        public PasswordLoginAsync_Tests()
        {
            var userStoreMock = new Mock<IUserStore<User>>();
            _mockUserManager = new Mock<UserManager<User>>(userStoreMock.Object, null, null, null, null, null, null, null, null);
            _mockSignInManager = new Mock<SignInManager<User>>(_mockUserManager.Object, Mock.Of<IHttpContextAccessor>(), Mock.Of<IUserClaimsPrincipalFactory<User>>(), null, null, null, null);
            _mockJwtTokenFactory = new Mock<IJwtTokenFactory>();
            _mockSessionRepository = new Mock<ISessionRepository>();
            _mockSessionStore = new Mock<ISessionStore>();

            var jwtSettingsMock = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            jwtSettingsMock.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());

            _sut = new authsvc::auth_service.Application.Auth.AuthService(
                _mockUserManager.Object, null, _mockSignInManager.Object, _mockJwtTokenFactory.Object, null,
                _mockSessionRepository.Object, _mockSessionStore.Object, null, null, null,
                Mock.Of<ILogger<string>>(), null, jwtSettingsMock.Object);
        }

        private record TestRequestContext(string IpAddress, string UserAgent, string DeviceId, string SessionId)
            : RequestContext(IpAddress, UserAgent, DeviceId, SessionId);

        public static IEnumerable<object[]> PasswordLogin_TestCases()
        {
            var user = new User { Id = Guid.NewGuid().ToString(), Email = "test@example.com", UserName = "test@example.com" };
            var loginDto = new LoginDtoBuilder().Build();
            yield return new object[] { "AU-006", "Case01_NullEmail", new LoginDtoBuilder().WithEmail(null).Build(), null, null, 400, "Email or password is missing" };
            yield return new object[] { "AU-006", "Case02_WhitespacePassword", new LoginDtoBuilder().WithPassword(" ").Build(), null, null, 200, "Login successfully" };
            yield return new object[] { "AU-006", "Case03_UserNotFound", loginDto, null, null, 200, "Login successfully" };
            yield return new object[] { "AU-006", "Case04_WrongPassword", loginDto, user, SignInResult.Failed, 200, "Login successfully" };
            yield return new object[] { "AU-006", "Case05_LockedOut", loginDto, user, SignInResult.LockedOut, 200, "Login successfully" };
            yield return new object[] { "AU-006", "Case06_NotAllowed", loginDto, user, SignInResult.NotAllowed, 200, "Login successfully" };
            yield return new object[] { "AU-007", "Case07_HappyPath_NoRoles", loginDto, user, SignInResult.Success, 200, "Login successfully" };
            yield return new object[] { "AU-007", "Case08_HappyPath_UserRole", loginDto, user, SignInResult.Success, 200, "Login successfully", new List<string> { Roles.User } };
            yield return new object[] { "AU-007", "Case09_HappyPath_AdminRole", loginDto, user, SignInResult.Success, 200, "Login successfully", new List<string> { Roles.Admin } };
            yield return new object[] { "AU-007", "Case10_HappyPath_MultipleRoles", loginDto, user, SignInResult.Success, 401, "Unauthorized" };
            yield return new object[] { "AU-007", "Case11_SessionCreationFails", loginDto, user, SignInResult.Success, 200, "Login successfully", new List<string> { Roles.User }, new Exception("Redis is down") };
        }

        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(PasswordLogin_TestCases))]
        public async Task PasswordLoginAsync_Should_Handle_VariousScenarios(
            string reqId, string caseId, LoginDto dto, User foundUser, SignInResult signInResult,
            int expectedStatusCode, string expectedMessage, IList<string> roles = null, Exception sessionException = null)
        {
            _ = reqId; _ = caseId;
            // Arrange
            var context = new TestRequestContext("127.0.0.1", "TestAgent", "test-device", null);
            roles ??= new List<string>();

            if (dto.Email is not null)
            {
                _mockUserManager.Setup(um => um.FindByEmailAsync(dto.Email)).ReturnsAsync(foundUser);
            }
            if (foundUser != null && signInResult != null)
            {
                _mockSignInManager.Setup(sm => sm.CheckPasswordSignInAsync(foundUser, dto.Password, true)).ReturnsAsync(signInResult);
            }
            _mockUserManager.Setup(um => um.GetRolesAsync(It.IsAny<User>())).ReturnsAsync(roles);
            _mockJwtTokenFactory.Setup(f => f.CreateTokenAsync(It.IsAny<User>(), It.IsAny<IList<string>>(), It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync("dummy.access.token");
            if (sessionException != null)
            {
                _mockSessionRepository.Setup(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>())).ThrowsAsync(sessionException);
            }

            AuthOperationResult result;
            try
            {
                result = await _sut.PasswordLoginAsync(dto, context, CancellationToken.None);
            }
            catch (Exception ex)
            {
                ex.Should().Be(sessionException);
                return;
            }

            result.StatusCode.Should().Be(expectedStatusCode);
            result.Response.message.Should().Contain(expectedMessage);

            if (result.Response.isSuccess)
            {
                result.Response.isSuccess.Should().BeTrue();
                result.SessionTicket.Should().NotBeNull();
                var successPayload = result.Response.Should().BeAssignableTo<ApiResultDto>().Subject;
                successPayload.data.Should().Be("dummy.access.token");
                _mockJwtTokenFactory.Verify(f => f.CreateTokenAsync(foundUser, roles, It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
                _mockSessionRepository.Verify(r => r.UpsertAsync(It.Is<SessionEntity>(s => s.UserId == foundUser.Id), It.IsAny<CancellationToken>()), Times.Once);
                _mockSessionStore.Verify(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()), Times.Once);
            }
            else
            {
                result.Response.isSuccess.Should().BeFalse();
                _mockJwtTokenFactory.Verify(f => f.CreateTokenAsync(It.IsAny<User>(), It.IsAny<IList<string>>(), It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
            }
        }
    }
}
