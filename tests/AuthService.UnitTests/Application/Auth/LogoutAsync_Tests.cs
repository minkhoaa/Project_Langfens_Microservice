extern alias authsvc;

using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using FluentAssertions;
using Moq;
using Shared.ExamDto.Contracts;
using Xunit;
using AuthOperationResult = authsvc::auth_service.Application.Auth.AuthOperationResult;
using SUTAuthService = authsvc::auth_service.Application.Auth.AuthService;
using ISessionRepository = authsvc::auth_service.Infrastructure.Persistence.ISessionRepository;
using ISessionStore = authsvc::auth_service.Infrastructure.Redis.ISessionStore;
using RequestContext = authsvc::auth_service.Application.Common.RequestContext;
using SessionEntity = authsvc::auth_service.Data.SessionEntity;
using SessionRecord = authsvc::auth_service.Infrastructure.Redis.SessionRecord;
using User = authsvc::auth_service.Infrastructure.Persistence.User;
using Role = authsvc::auth_service.Infrastructure.Persistence.Role;

namespace AuthService.UnitTests.Application.Auth
{
    public class LogoutAsync_Tests
    {
        private readonly Mock<ISessionRepository> _mockSessionRepository;
        private readonly Mock<ISessionStore> _mockSessionStore;
        private readonly SUTAuthService _sut;

        private record TestRequestContext(string IpAddress, string UserAgent, string DeviceId, string SessionId)
            : RequestContext(IpAddress, UserAgent, DeviceId, SessionId);

        public LogoutAsync_Tests()
        {
            _mockSessionRepository = new Mock<ISessionRepository>();
            _mockSessionStore = new Mock<ISessionStore>();

            var jwtSettingsMock = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            jwtSettingsMock.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());

            _sut = new SUTAuthService(
                null, null, null, null, null,
                _mockSessionRepository.Object,
                _mockSessionStore.Object,
                null, null, null,
                Mock.Of<ILogger<string>>(), null, jwtSettingsMock.Object
            );
        }

        public static IEnumerable<object[]> Logout_TestCases()
        {
            var userId = Guid.NewGuid().ToString();
            var sid = Guid.NewGuid().ToString("N");
            var deviceId = "device-123";
            yield return new object[] { "AU-011", "Case01_NoSessionId", new TestRequestContext(null, null, null, null), null, null, false };
            yield return new object[] { "AU-011", "Case02_SessionNotInStore", new TestRequestContext(null, null, deviceId, sid), null, null, false };
            yield return new object[] { "AU-011", "Case03_SessionInStore_NoDeviceId", new TestRequestContext(null, null, null, sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), null, null, null), null, false };
            yield return new object[] { "AU-011", "Case04_DbSessionNotFound", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), deviceId, null, null), null, false };
            yield return new object[] { "AU-011", "Case05_HappyPath", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), deviceId, null, null), new SessionEntity(), true };
            yield return new object[] { "AU-011", "Case06_SessionStoreThrows", new TestRequestContext(null, null, deviceId, sid), null, null, false, new Exception("Redis down") };
            yield return new object[] { "AU-011", "Case07_RepoThrows", new TestRequestContext(null, null, deviceId, sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), deviceId, null, null), new SessionEntity(), true, null, new Exception("DB down") };
            yield return new object[] { "AU-011", "Case08_SessionId_Is_Whitespace", new TestRequestContext(null, null, null, "  "), null, null, false };
            yield return new object[] { "AU-011", "Case09_SessionInStore_Has_Whitespace_DeviceId", new TestRequestContext(null, null, "  ", sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), "  ", null, null), null, false };
            yield return new object[] { "AU-011", "Case10_SessionInStore_Has_Empty_DeviceId", new TestRequestContext(null, null, "", sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), "", null, null), null, false };
            yield return new object[] { "AU-011", "Case11_FullContext", new TestRequestContext("1.1.1.1", "Agent", deviceId, sid), new SessionRecord(sid, userId, null, DateTime.UtcNow.AddDays(1), deviceId, null, null), new SessionEntity(), true };
        }

        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(Logout_TestCases))]
        public async Task LogoutAsync_Should_AlwaysSucceedAndClearSession(
            string reqId, string caseId, RequestContext context, SessionRecord sessionInStore,
            SessionEntity sessionInDb, bool shouldSetRevoked, Exception sessionStoreException = null, Exception repoException = null)
        {
            _ = reqId; _ = caseId;
            if (context.SessionId != null)
            {
                if (sessionStoreException != null)
                    _mockSessionStore.Setup(s => s.GetSessionAsync(context.SessionId, It.IsAny<CancellationToken>())).ThrowsAsync(sessionStoreException);
                else
                    _mockSessionStore.Setup(s => s.GetSessionAsync(context.SessionId, It.IsAny<CancellationToken>())).ReturnsAsync(sessionInStore);
            }
            if (sessionInStore?.DeviceId != null)
            {
                if (repoException != null)
                    _mockSessionRepository.Setup(r => r.FindAsync(sessionInStore.UserId, sessionInStore.DeviceId, It.IsAny<CancellationToken>())).ThrowsAsync(repoException);
                else
                    _mockSessionRepository.Setup(r => r.FindAsync(sessionInStore.UserId, sessionInStore.DeviceId, It.IsAny<CancellationToken>())).ReturnsAsync(sessionInDb);
            }

            AuthOperationResult result;
            try
            {
                result = await _sut.LogoutAsync(context, CancellationToken.None);
            }
            catch (Exception ex)
            {
                ex.Should().Be(repoException ?? sessionStoreException);
                return;
            }

            result.Response.isSuccess.Should().BeTrue();
            var payload = result.Response.Should().BeAssignableTo<ApiResultDto>().Subject;
            payload.message.Should().Be("Logout successfully");

            if (sessionInStore != null)
            {
                if (sessionStoreException == null && repoException == null)
                    _mockSessionStore.Verify(s => s.RemoveSessionAsync(sessionInStore, It.IsAny<CancellationToken>()), Times.Once);
                else
                    _mockSessionStore.Verify(s => s.RemoveSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<CancellationToken>()), Times.Never);

                if (shouldSetRevoked)
                {
                    if (sessionStoreException == null && repoException == null)
                        _mockSessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
                    else
                         _mockSessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);

                    sessionInDb.RevokedAt.Should().NotBeNull();
                }
            }
            else
            {
                _mockSessionStore.Verify(s => s.RemoveSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<CancellationToken>()), Times.Never);
                _mockSessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
            }
        }
    }
}
