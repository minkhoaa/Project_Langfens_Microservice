using Shared.Security.Claims;

namespace AuthService.UnitTests.Auth;

public class AuthCurrentUserTests
{
    [Fact]
    public async Task GetCurrentUserAsync_Should_Return_Unauthorized_When_NotAuthenticated()
    {
        var builder = new AuthServiceTestBuilder();
        var service = builder.Build();
        var principal = new ClaimsPrincipal(new ClaimsIdentity());

        var result = await service.GetCurrentUserAsync(principal);

        result.StatusCode.Should().Be(StatusCodes.Status401Unauthorized);
    }

    [Fact]
    public async Task GetCurrentUserAsync_Should_Return_NotFound_When_EmailMissing()
    {
        var builder = new AuthServiceTestBuilder();
        builder.UserManager.Setup(m => m.FindByIdAsync("user-1")).ReturnsAsync((User?)null);
        var service = builder.Build();
        var identity = new ClaimsIdentity(new[]
        {
            new Claim(CustomClaims.Sub, "user-1")
        }, authenticationType: "pwd");
        var principal = new ClaimsPrincipal(identity);

        var result = await service.GetCurrentUserAsync(principal);

        result.StatusCode.Should().Be(StatusCodes.Status404NotFound);
    }

    [Fact]
    public async Task GetCurrentUserAsync_Should_Return_Profile_When_EmailConfirmed()
    {
        var builder = new AuthServiceTestBuilder();
        var user = new User { Email = "user@example.com", EmailConfirmed = true, Id = "user-1" };
        builder.UserManager.Setup(m => m.FindByIdAsync("user-1")).ReturnsAsync(user);
        var service = builder.Build();

        var identity = new ClaimsIdentity(new[]
        {
            new Claim(ClaimTypes.Email, "user@example.com"),
            new Claim(CustomClaims.Sub, "user-1")
        }, authenticationType: "pwd");
        var principal = new ClaimsPrincipal(identity);

        var result = await service.GetCurrentUserAsync(principal);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.data.Should().NotBeNull();
    }
}