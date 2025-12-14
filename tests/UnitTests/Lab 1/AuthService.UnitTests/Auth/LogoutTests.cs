namespace AuthService.UnitTests.Auth;

public class LogoutTests
{
    [Fact]
    public async Task Logout_Should_ClearCookie_When_NoSessionId()
    {
        var b = new AuthServiceTestBuilder();
        var service = b.Build();
        var ctx = new RequestContext(null, "ua", "127.0.0.1", null);

        var result = await service.LogoutAsync(ctx, CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.ShouldClearSessionCookie.Should().BeTrue();
    }
}
