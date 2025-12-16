extern alias authsvc;
using authsvc::auth_service.Application.Auth;
using authsvc::auth_service.Application.Common;
using authsvc::auth_service.Data;
using authsvc::auth_service.Infrastructure.Persistence;
using authsvc::auth_service.Infrastructure.Redis;
using FluentAssertions;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Time.Testing;
using Moq;
using Shared.ExamDto.Contracts;
using Xunit;

namespace AuthService.UnitTests.Application.Auth
{
    public class RefreshAsync_Tests
    {
        private readonly Mock<UserManager<User>> _mockUserManager;
        private readonly Mock<IJwtTokenFactory> _mockJwtTokenFactory;
        private readonly Mock<ISessionRepository> _mockSessionRepository;
        private readonly Mock<ISessionStore> _mockSessionStore;
        private readonly FakeTimeProvider _fakeTimeProvider;
        private readonly authsvc::auth_service.Application.Auth.AuthService _sut;

        private record TestRequestContext(string IpAddress, string UserAgent, string DeviceId, string SessionId)
            : RequestContext(IpAddress, UserAgent, DeviceId, SessionId);

        public RefreshAsync_Tests()
        {
            var userStoreMock = new Mock<IUserStore<User>>();
            _mockUserManager = new Mock<UserManager<User>>(userStoreMock.Object, null, null, null, null, null, null, null, null);
            _mockJwtTokenFactory = new Mock<IJwtTokenFactory>();
            _mockSessionRepository = new Mock<ISessionRepository>();
            _mockSessionStore = new Mock<ISessionStore>();
            _fakeTimeProvider = new FakeTimeProvider();

            var jwtSettingsMock = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            jwtSettingsMock.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());

            _sut = new authsvc::auth_service.Application.Auth.AuthService(
                _mockUserManager.Object, null, null, _mockJwtTokenFactory.Object, null,
                _mockSessionRepository.Object, _mockSessionStore.Object, null, null, null,
                Mock.Of<ILogger<string>>(), null, jwtSettingsMock.Object);
        }

        public static IEnumerable<object[]> RefreshAsync_TestCases()
        {
            var now = DateTime.UtcNow;
            var userId = Guid.NewGuid().ToString();
            var user = new User { Id = userId, Email = "test@example.com" };
            var sid = Guid.NewGuid().ToString("N");
            var jti = Guid.NewGuid().ToString("N");
            var deviceId = "device-123";
            yield return new object[] { "AU-008", "Case01_NoSessionId", new TestRequestContext(null, null, deviceId, null), null, null, null, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case02_SessionNotInStore", new TestRequestContext(null, null, deviceId, sid), null, null, null, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case03_SessionInStoreIsExpired", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddSeconds(-1), deviceId, null, null), null, null, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case04_UserNotFound", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), null, null, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case05_DbSessionNotFound", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), user, null, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case06_DbSessionRevoked", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), user, new SessionEntity { RevokedAt = now.AddMinutes(-5) }, "Unauthorized", true };
            yield return new object[] { "AU-008", "Case07_JtiMismatch", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, "redis-jti", now.AddDays(1), deviceId, null, null), user, new SessionEntity { Jti = "db-jti" }, "Unauthorized", true };
            yield return new object[] { "AU-009", "Case08_SuccessNoRotation", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(10), deviceId, null, null), user, new SessionEntity { UserId = userId, DeviceId = deviceId, Jti = jti, Exp = now.AddDays(10), LastSeen = now.AddHours(-1) }, "Success", false };
            yield return new object[] { "AU-010", "Case09_SuccessWithRotation", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), user, new SessionEntity { UserId = userId, DeviceId = deviceId, Jti = jti, Exp = now.AddDays(1), LastSeen = now.AddHours(-1) }, "Success", false };
            yield return new object[] { "AU-008", "Case10_DbSessionExactlyExpired", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), user, new SessionEntity { UserId = userId, DeviceId = deviceId, Jti = jti, Exp = now, LastSeen = now.AddHours(-1) }, "Unauthorized", true };
            yield return new object[] { "AU-010", "Case11_RotationChangesJti", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, jti, now.AddDays(1), deviceId, null, null), user, new SessionEntity { UserId = userId, DeviceId = deviceId, Jti = jti, Exp = now.AddDays(1), LastSeen = now.AddHours(-1) }, "Success", false };
        }

        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(RefreshAsync_TestCases))]
        public async Task RefreshAsync_Should_Handle_SessionStatesCorrectly(
            string reqId, string caseId, RequestContext context, SessionRecord sessionInStore, User user, SessionEntity sessionInDb, string expectedMessage, bool expectUnauthorized)
        {
            _ = reqId; _ = caseId; _ = expectedMessage;
            
            if (context.SessionId != null)
            {
                _mockSessionStore.Setup(s => s.GetSessionAsync(context.SessionId, It.IsAny<CancellationToken>())).ReturnsAsync(sessionInStore);
            }
            if (sessionInStore != null)
            {
                _mockUserManager.Setup(um => um.FindByIdAsync(sessionInStore.UserId)).ReturnsAsync(user);
            }
            if (user != null && sessionInStore?.DeviceId != null)
            {
                _mockSessionRepository.Setup(r => r.FindAsync(user.Id, sessionInStore.DeviceId, It.IsAny<CancellationToken>())).ReturnsAsync(sessionInDb);
            }
            _mockUserManager.Setup(um => um.GetRolesAsync(It.IsAny<User>())).ReturnsAsync(new List<string>());
            _mockJwtTokenFactory.Setup(f => f.CreateTokenAsync(It.IsAny<User>(), It.IsAny<IList<string>>(), It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync("new.refreshed.token");

            var originalExp = sessionInDb?.Exp;
            var originalJti = sessionInDb?.Jti;
            var result = await _sut.RefreshAsync(context, CancellationToken.None);

            if (expectUnauthorized)
            {
                result.StatusCode.Should().Be(401);
            }
            else
            {
                result.StatusCode.Should().Be(200);
                result.Response.isSuccess.Should().BeTrue();
                var payload = result.Response.Should().BeAssignableTo<ApiResultDto>().Subject;
                payload.data.Should().Be("new.refreshed.token");

                // Calculate logic based on what the service saw (originalExp), not updated Exp
                var needsRotation = (originalExp.HasValue) && (originalExp.Value - DateTime.UtcNow < TimeSpan.FromDays(3));
                if (needsRotation)
                {
                    _mockSessionStore.Verify(s => s.StoreSessionAsync(It.Is<SessionRecord>(r => r.Jti != originalJti && r.Sid == sessionInStore.Sid), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()), Times.Once);
                    sessionInDb.PrevJti.Should().Be(originalJti);
                }
                else
                {
                    _mockSessionStore.Verify(s => s.RefreshSessionTtlAsync(context.SessionId, It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()), Times.Once);
                }
                _mockSessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
            }
        }
    }
}
