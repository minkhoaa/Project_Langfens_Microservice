using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using auth_service.Application.Common;
using Xunit;

namespace auth_service.Application.Common.UnitTests;

public class CookieServiceTests
{
    private readonly Faker _faker = new();

    private CookieService CreateService(Dictionary<string, string?> overrides)
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(overrides!)
            .Build();
        return new CookieService(config);
    }

    [Fact]
    public void CreateSessionCookie_WithDomainConfigured_ShouldSetDomainAndSecure()
    {
        var expiresAt = _faker.Date.SoonOffset().ToUniversalTime();
        var domain = _faker.Internet.DomainName();
        var service = CreateService(new()
        {
            ["Cookies:Secure"] = "true",
            ["Cookies:Domain"] = domain
        });

        var result = service.CreateSessionCookie(expiresAt);

        result.HttpOnly.Should().BeTrue();
        result.SameSite.Should().Be(SameSiteMode.Lax);
        result.Secure.Should().BeTrue();
        result.Path.Should().Be("/");
        result.Expires.Should().Be(expiresAt);
        result.IsEssential.Should().BeTrue();
        result.Domain.Should().Be(domain);
    }

    [Fact]
    public void CreateSessionCookie_WhenDomainMissing_ShouldSkipDomain()
    {
        var expiresAt = _faker.Date.SoonOffset().ToUniversalTime();
        var service = CreateService(new()
        {
            ["Cookies:Secure"] = "false"
        });

        var result = service.CreateSessionCookie(expiresAt);

        result.Secure.Should().BeFalse();
        result.Domain.Should().BeNull();
        result.Expires.Should().Be(expiresAt);
        result.HttpOnly.Should().BeTrue();
        result.SameSite.Should().Be(SameSiteMode.Lax);
        result.IsEssential.Should().BeTrue();
        result.Path.Should().Be("/");
    }

    [Fact]
    public void CreateRemovalCookie_WithDomainConfigured_ShouldSetEpochExpiryAndDomain()
    {
        var domain = _faker.Internet.DomainName();
        var service = CreateService(new()
        {
            ["Cookies:Secure"] = "true",
            ["Cookies:Domain"] = domain
        });

        var result = service.CreateRemovalCookie();

        result.HttpOnly.Should().BeTrue();
        result.SameSite.Should().Be(SameSiteMode.Lax);
        result.Secure.Should().BeTrue();
        result.Path.Should().Be("/");
        result.Expires.Should().Be(DateTimeOffset.UnixEpoch);
        result.IsEssential.Should().BeTrue();
        result.Domain.Should().Be(domain);
    }

    [Fact]
    public void CreateRemovalCookie_WhenDomainMissing_ShouldSkipDomain()
    {
        var service = CreateService(new()
        {
            ["Cookies:Secure"] = "false"
        });

        var result = service.CreateRemovalCookie();

        result.Secure.Should().BeFalse();
        result.Domain.Should().BeNull();
        result.Expires.Should().Be(DateTimeOffset.UnixEpoch);
        result.HttpOnly.Should().BeTrue();
        result.SameSite.Should().Be(SameSiteMode.Lax);
        result.IsEssential.Should().BeTrue();
        result.Path.Should().Be("/");
    }
}
