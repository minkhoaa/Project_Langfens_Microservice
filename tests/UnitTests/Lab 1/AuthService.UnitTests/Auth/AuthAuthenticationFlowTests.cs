namespace AuthService.UnitTests.Auth;

public class AuthAuthenticationFlowTests
{
    [Fact]
    public async Task PasswordLoginAsync_Should_Issue_Tokens_When_Credentials_Are_Valid()
    {
        var builder = new AuthServiceTestBuilder();
        var user = new User { Id = "user-1", Email = "user@example.com", UserName = "user@example.com" };
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com")).ReturnsAsync(user);
        builder.SignInManager.Setup(m => m.CheckPasswordSignInAsync(user, "Pass123!", true))
            .ReturnsAsync(SignInResult.Success);
        builder.UserManager.Setup(m => m.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        builder.JwtTokenFactory.Setup(f => f.CreateTokenAsync(
                user,
                It.IsAny<IEnumerable<string>>(),
                It.IsAny<IEnumerable<string>>(),
                It.IsAny<string>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync("jwt-token");
        var service = builder.Build();

        var result = await service.PasswordLoginAsync(
            new LoginDto("user@example.com", "Pass123!"),
            new RequestContext("device-1", "agent", "127.0.0.1", null),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.data.Should().Be("jwt-token");
        result.SessionTicket.Should().NotBeNull();
        builder.SessionRepository.Verify(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>()),
            Times.Once);
        builder.SessionStore.Verify(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task PasswordLoginAsync_Should_Return_BadRequest_When_Password_Incorrect()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("user@example.com"))
            .ReturnsAsync(new User { Id = "user-1", Email = "user@example.com" });
        builder.SignInManager.Setup(m => m.CheckPasswordSignInAsync(It.IsAny<User>(), It.IsAny<string>(), true))
            .ReturnsAsync(SignInResult.Failed);
        var service = builder.Build();

        var result = await service.PasswordLoginAsync(
            new LoginDto("user@example.com", "wrong"),
            new RequestContext("device-1", "agent", "127.0.0.1", null),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.message.Should().Contain("incorrect");
        result.SessionTicket.Should().BeNull();
    }

    [Fact]
    public async Task PasswordLoginAsync_Should_Return_BadRequest_When_User_Not_Found()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByEmailAsync("missing@example.com"))
            .ReturnsAsync((User?)null);
        var service = builder.Build();

        var result = await service.PasswordLoginAsync(
            new LoginDto("missing@example.com", "whatever"),
            new RequestContext("device-1", "agent", "127.0.0.1", null),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.message.Should().Contain("not existed");
        builder.SignInManager.Verify(m => m.CheckPasswordSignInAsync(It.IsAny<User>(), It.IsAny<string>(), true),
            Times.Never);
    }

    [Fact]
    public async Task RefreshAsync_Should_Rotate_Session_When_Expiring()
    {
        var builder = new AuthServiceTestBuilder();
        var user = new User { Id = "user-1", Email = "user@example.com" };
        var now = DateTime.UtcNow;
        var sessionRecord = new SessionRecord(
            "sid-1",
            "user-1",
            "jti-old",
            now.AddHours(1),
            "device-1",
            "agent",
            "127.0.0.1");

        builder.SessionStore.Setup(s => s.GetSessionAsync("sid-1", It.IsAny<CancellationToken>()))
            .ReturnsAsync(sessionRecord);
        builder.UserManager.Setup(m => m.FindByIdAsync("user-1")).ReturnsAsync(user);
        builder.SessionRepository.Setup(r => r.FindAsync("user-1", "device-1", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new SessionEntity
            {
                UserId = "user-1",
                DeviceId = "device-1",
                Jti = "jti-old",
                Exp = now.AddHours(1)
            });
        builder.UserManager.Setup(m => m.GetRolesAsync(user)).ReturnsAsync(Array.Empty<string>());
        builder.JwtTokenFactory.Setup(f => f.CreateTokenAsync(
                user,
                It.IsAny<IEnumerable<string>>(),
                It.IsAny<IEnumerable<string>>(),
                It.IsAny<string>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync("new-jwt");
        var service = builder.Build();

        var result = await service.RefreshAsync(
            new RequestContext("device-1", "agent-new", "127.0.0.2", "sid-1"),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.data.Should().Be("new-jwt");
        builder.SessionStore.Verify(s =>
                s.StoreSessionAsync(It.Is<SessionRecord>(sr => sr.Jti != "jti-old"), It.IsAny<TimeSpan>(),
                    It.IsAny<CancellationToken>()),
            Times.Once);
        builder.SessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task LogoutAsync_Should_Revoke_Session_When_SessionId_Present()
    {
        var builder = new AuthServiceTestBuilder();
        var sessionRecord = new SessionRecord("sid", "user-1", "jti", DateTime.UtcNow.AddHours(1), "device-1", null, null);
        builder.SessionStore.Setup(s => s.GetSessionAsync("sid", It.IsAny<CancellationToken>()))
            .ReturnsAsync(sessionRecord);
        builder.SessionRepository.Setup(r => r.FindAsync("user-1", "device-1", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new SessionEntity { UserId = "user-1", DeviceId = "device-1", Jti = "jti" });
        var service = builder.Build();

        var result = await service.LogoutAsync(new RequestContext(null, null, null, "sid"), CancellationToken.None);

        result.Response.isSuccess.Should().BeTrue();
        result.ShouldClearSessionCookie.Should().BeTrue();
        builder.SessionStore.Verify(s => s.RemoveSessionAsync(sessionRecord, It.IsAny<CancellationToken>()), Times.Once);
        builder.SessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GoogleLoginAsync_Should_Return_BadRequest_When_IdToken_Missing()
    {
        var builder = new AuthServiceTestBuilder();
        var service = builder.Build();

        var result = await service.GoogleLoginAsync(new GoogleLoginRequest(null),
            new RequestContext(null, null, null, null), CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.message.Should().Contain("Missing Token");
    }
}
