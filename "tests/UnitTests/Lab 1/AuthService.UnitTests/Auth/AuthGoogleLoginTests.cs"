using Google.Apis.Auth;
using Shared.Security.Roles;

namespace AuthService.UnitTests.Auth;

public class AuthGoogleLoginTests
{
    [Fact]
    public async Task GoogleLogin_Should_Create_User_And_Return_Token()
    {
        // arrange
        var b = new AuthServiceTestBuilder();
        var service = b.Build();
        var device = "device-1";
        var ctx = new RequestContext(device, "ua", "127.0.0.1", sessionId: null);

        var payload = new GoogleJsonWebSignature.Payload
        {
            Email = "user@example.com",
            EmailVerified = true,
            Subject = "google-sub"
        };

        b.GoogleTokenVerifier.Setup(v => v.VerifyAsync("id-token", It.IsAny<CancellationToken>()))
            .ReturnsAsync(payload);
        b.EmailValidator.Setup(v => v.IsValid(It.IsAny<string>())).Returns(true);

        b.UserManager.Setup(m => m.FindByLoginAsync("Google", payload.Subject, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
        b.UserManager.Setup(m => m.FindByEmailAsync(payload.Email)).ReturnsAsync((User?)null);
        b.UserManager.Setup(m => m.CreateAsync(It.IsAny<User>())).ReturnsAsync(IdentityResult.Success);
        b.RoleManager.Setup(r => r.RoleExistsAsync(Roles.User)).ReturnsAsync(true);
        b.UserManager.Setup(m => m.IsInRoleAsync(It.IsAny<User>(), Roles.User)).ReturnsAsync(false);
        b.UserManager.Setup(m => m.AddToRoleAsync(It.IsAny<User>(), Roles.User))
            .ReturnsAsync(IdentityResult.Success);
        b.UserManager.Setup(m => m.AddLoginAsync(It.IsAny<User>(), It.IsAny<UserLoginInfo>()))
            .ReturnsAsync(IdentityResult.Success);
        b.UserManager.Setup(m => m.GetRolesAsync(It.IsAny<User>())).ReturnsAsync(new List<string>());

        b.SessionRepository.Setup(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((SessionEntity se, CancellationToken _) => se);
        b.JwtTokenFactory.Setup(f => f.CreateTokenAsync(It.IsAny<User>(), It.IsAny<IEnumerable<string>>(),
                It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync("jwt-token");

        // act
        var result = await service.GoogleLoginAsync(new GoogleLoginRequest { IdToken = "id-token" }, ctx,
            CancellationToken.None);

        // assert
        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.isSuccess.Should().BeTrue();
        result.SessionTicket.Should().NotBeNull();
        b.SessionStore.Verify(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GoogleLogin_Should_Return_BadRequest_When_Verification_Fails()
    {
        var b = new AuthServiceTestBuilder();
        var service = b.Build();
        var ctx = new RequestContext("device-1", "ua", "127.0.0.1", null);
        b.GoogleTokenVerifier.Setup(v => v.VerifyAsync("bad-token", It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("invalid token"));

        var result = await service.GoogleLoginAsync(new GoogleLoginRequest { IdToken = "bad-token" }, ctx,
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.isSuccess.Should().BeFalse();
    }
}
