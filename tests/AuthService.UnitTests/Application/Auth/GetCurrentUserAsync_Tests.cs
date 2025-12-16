extern alias authsvc;
using authsvc::auth_service.Application.Auth;
using authsvc::auth_service.Data;
using FluentAssertions;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using Moq;
using Shared.ExamDto.Contracts;
using System.Security.Claims;
using Shared.Security.Claims;
using Xunit;
using User = authsvc::auth_service.Infrastructure.Persistence.User;

namespace AuthService.UnitTests.Application.Auth
{
    public class GetCurrentUserAsync_Tests
    {
        private readonly Mock<UserManager<User>> _mockUserManager;
        private readonly authsvc::auth_service.Application.Auth.AuthService _sut;
        public GetCurrentUserAsync_Tests()
        {
            var userStoreMock = new Mock<IUserStore<User>>();
            _mockUserManager = new Mock<UserManager<User>>(userStoreMock.Object, null, null, null, null, null, null, null, null);
            var jwtSettingsMock = new Mock<IOptions<authsvc::auth_service.Application.Common.JwtSettings>>();
            jwtSettingsMock.Setup(x => x.Value).Returns(new authsvc::auth_service.Application.Common.JwtSettings());
            _sut = new authsvc::auth_service.Application.Auth.AuthService(_mockUserManager.Object, null, null, null, null, null, null, null, null, null, null, null, jwtSettingsMock.Object);
        }
        private static ClaimsPrincipal CreatePrincipal(bool isAuthenticated, string subClaimValue = null)
        {
            var claims = new List<Claim>();
            if (subClaimValue != null) { claims.Add(new Claim(CustomClaims.Sub, subClaimValue)); }
            var identity = new ClaimsIdentity(isAuthenticated ? claims : new List<Claim>(), isAuthenticated ? "TestAuth" : null);
            return new ClaimsPrincipal(identity);
        }
        public static IEnumerable<object?[]> GetCurrentUser_TestCases()
        {
            var userId = Guid.NewGuid().ToString();
            var user = new User { Id = userId, Email = "test@example.com", EmailConfirmed = true };
            var adminUser = new User { Id = Guid.NewGuid().ToString(), Email = "admin@example.com", EmailConfirmed = true };
            var unconfirmedUser = new User { Id = Guid.NewGuid().ToString(), Email = "unconfirmed@example.com", EmailConfirmed = false };
            
            // AU-012: Failures
            yield return new object?[] { "AU-012", "Case01_NotAuthenticated", CreatePrincipal(false), null, 401, "Unauthorized" };
            yield return new object?[] { "AU-012", "Case02_AuthenticatedNoSubClaim", CreatePrincipal(true), null, 401, "Unauthorized" };
            yield return new object?[] { "AU-012", "Case03_UserNotFound", CreatePrincipal(true, Guid.NewGuid().ToString()), null, 404, "User not found" };
            yield return new object?[] { "AU-012", "Case04_EmptySubClaim", CreatePrincipal(true, ""), null, 404, "User not found" };
            yield return new object?[] { "AU-012", "Case05_WhitespaceSubClaim", CreatePrincipal(true, "   "), null, 404, "User not found" };
            yield return new object?[] { "AU-012", "Case06_InvalidGuidFormat", CreatePrincipal(true, "not-a-guid"), null, 404, "User not found" };
            
            // AU-012: Success
            yield return new object?[] { "AU-012", "Case07_Success", CreatePrincipal(true, userId), user, 200, "Get information successfully" };
            yield return new object?[] { "AU-012", "Case08_AdminUserSuccess", CreatePrincipal(true, adminUser.Id), adminUser, 200, "Get information successfully" };
            yield return new object?[] { "AU-012", "Case09_UnconfirmedUserSuccess", CreatePrincipal(true, unconfirmedUser.Id), unconfirmedUser, 200, "Get information successfully" };
            yield return new object?[] { "AU-012", "Case10_ValidGuidFormatN", CreatePrincipal(true, Guid.NewGuid().ToString("N")), null, 404, "User not found" };
            yield return new object?[] { "AU-012", "Case11_UppercaseGuid", CreatePrincipal(true, userId.ToUpperInvariant()), null, 404, "User not found" };
        }
        [Theory(DisplayName = "{0} {1}")]
        [MemberData(nameof(GetCurrentUser_TestCases))]
        public async Task GetCurrentUserAsync_Should_ReturnCorrectResult_BasedOn_Principal(
            string reqId, string caseId, ClaimsPrincipal principal, User foundUser, int expectedStatusCode, string expectedMessage)
        {
            _ = reqId; _ = caseId; _ = expectedMessage;
            var subClaim = principal.FindFirst(CustomClaims.Sub)?.Value;
            if (subClaim != null) { _mockUserManager.Setup(um => um.FindByIdAsync(subClaim)).ReturnsAsync(foundUser); }
            var result = await _sut.GetCurrentUserAsync(principal);
            result.StatusCode.Should().Be(expectedStatusCode);
        }
    }
}
