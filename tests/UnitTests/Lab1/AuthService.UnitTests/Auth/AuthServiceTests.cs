using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using auth_service.Application.Auth;
using auth_service.Application.Common;
using auth_service.Data;
using auth_service.Infrastructure.Persistence;
using auth_service.Infrastructure.Redis;
using Bogus;
using FluentAssertions;
using MassTransit;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Shared.Security.Roles;
using Xunit;

namespace auth_service.Application.Auth.UnitTests;

public class AuthServiceTests
{
    private readonly Faker _faker;
    private readonly Mock<UserManager<User>> _userManager;
    private readonly Mock<RoleManager<Role>> _roleManager;
    private readonly Mock<SignInManager<User>> _signInManager;
    private readonly Mock<IJwtTokenFactory> _jwtTokenFactory;
    private readonly Mock<IEmailValidator> _emailValidator;
    private readonly Mock<ISessionRepository> _sessionRepository;
    private readonly Mock<ISessionStore> _sessionStore;
    private readonly Mock<IGoogleTokenVerifier> _googleTokenVerifier;
    private readonly Mock<IOtpStore> _otpStore;
    private readonly Mock<IPublishEndpoint> _publishEndpoint;
    private readonly Mock<ILogger<string>> _logger;
    private readonly Mock<IOtpGenerator> _otpGenerator;
    private readonly Mock<IOptions<JwtSettings>> _jwtOptions;
    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _faker = new Faker();
        _userManager = CreateUserManager();
        _roleManager = CreateRoleManager();
        _signInManager = CreateSignInManager(_userManager.Object);
        _jwtTokenFactory = new Mock<IJwtTokenFactory>(MockBehavior.Strict);
        _emailValidator = new Mock<IEmailValidator>(MockBehavior.Strict);
        _sessionRepository = new Mock<ISessionRepository>(MockBehavior.Strict);
        _sessionStore = new Mock<ISessionStore>(MockBehavior.Strict);
        _googleTokenVerifier = new Mock<IGoogleTokenVerifier>(MockBehavior.Strict);
        _otpStore = new Mock<IOtpStore>(MockBehavior.Strict);
        _publishEndpoint = new Mock<IPublishEndpoint>(MockBehavior.Strict);
        _logger = new Mock<ILogger<string>>(MockBehavior.Strict);
        _otpGenerator = new Mock<IOtpGenerator>(MockBehavior.Strict);
        _jwtOptions = new Mock<IOptions<JwtSettings>>(MockBehavior.Strict);

        var jwtSettings = new JwtSettings
        {
            Issuer = _faker.Internet.DomainName(),
            Audience = _faker.Internet.DomainName(),
            SignKey = _faker.Random.Hexadecimal(32, string.Empty),
            RsaPrivateKeyPem = _faker.Random.AlphaNumeric(64),
            KeyId = _faker.Random.AlphaNumeric(8),
            AccessTokenLifetimeSeconds = _faker.Random.Int(600, 3600)
        };
        _jwtOptions.SetupGet(o => o.Value).Returns(jwtSettings);

        _sut = new AuthService(
            _userManager.Object,
            _roleManager.Object,
            _signInManager.Object,
            _jwtTokenFactory.Object,
            _emailValidator.Object,
            _sessionRepository.Object,
            _sessionStore.Object,
            _googleTokenVerifier.Object,
            _otpStore.Object,
            _publishEndpoint.Object,
            _logger.Object,
            _otpGenerator.Object,
            _jwtOptions.Object);
    }

    [Fact]
    public async Task PasswordLoginAsync_WithValidCredentials_ShouldIssueTokenAndPersistSession()
    {
        var email = _faker.Internet.Email();
        var password = _faker.Internet.Password(12);
        var deviceId = _faker.Random.Guid().ToString("N");
        var userAgent = _faker.Internet.UserAgent();
        var ip = _faker.Internet.Ip();
        var user = new User { Id = _faker.Random.Guid().ToString(), Email = email, UserName = email };
        var token = _faker.Random.AlphaNumeric(32);
        var capturedSession = (SessionEntity?)null;

        _userManager.Setup(m => m.FindByEmailAsync(email)).ReturnsAsync(user);
        _signInManager.Setup(m => m.CheckPasswordSignInAsync(user, password, true))
            .ReturnsAsync(SignInResult.Success);
        _userManager.Setup(m => m.GetRolesAsync(user))
            .ReturnsAsync(new List<string> { Roles.User });
        _sessionRepository.Setup(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((SessionEntity entity, CancellationToken _) =>
            {
                capturedSession = entity;
                return entity;
            });
        _sessionRepository.Setup(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        _sessionStore.Setup(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        _sessionStore.Setup(s => s.SetDeviceSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        _sessionStore.Setup(s => s.EnsureSessionLimitAsync(user.Id, It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        _jwtTokenFactory.Setup(f => f.CreateTokenAsync(user, It.IsAny<IEnumerable<string>>(),
                It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(token);

        var result = await _sut.PasswordLoginAsync(new LoginDto(email, password),
            new RequestContext(deviceId, userAgent, ip, null), CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status200OK);
        result.Response.isSuccess.Should().BeTrue();
        result.Response.message.Should().Contain("Login successfully");
        result.Response.data.Should().Be(token);
        result.SessionTicket.Should().NotBeNull();
        capturedSession.Should().NotBeNull();
        capturedSession!.UserId.Should().Be(user.Id);
        capturedSession.DeviceId.Should().Be(deviceId);
        _sessionRepository.Verify(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>()), Times.Once);
        _sessionRepository.Verify(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        _sessionStore.Verify(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()), Times.Once);
        _sessionStore.Verify(s => s.SetDeviceSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()), Times.Once);
        _sessionStore.Verify(s => s.EnsureSessionLimitAsync(user.Id, It.IsAny<int>(), It.IsAny<CancellationToken>()), Times.Once);
        _jwtTokenFactory.Verify(f => f.CreateTokenAsync(user, It.IsAny<IEnumerable<string>>(),
            It.IsAny<IEnumerable<string>>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task RegisterAsync_WhenEmailAlreadyExists_ShouldReturnFailure()
    {
        var email = _faker.Internet.Email().ToLowerInvariant();
        var password = _faker.Internet.Password(12);
        var user = new User { Id = _faker.Random.Guid().ToString(), Email = email };

        _emailValidator.Setup(v => v.IsValid(email)).Returns(true);
        _userManager.Setup(m => m.FindByEmailAsync(email)).ReturnsAsync(user);

        var result = await _sut.RegisterAsync(new RegisterDto(email, password), CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        result.Response.isSuccess.Should().BeFalse();
        result.Response.message.Should().Contain("already used");
        _userManager.Verify(m => m.FindByEmailAsync(email), Times.Once);
    }

    [Fact]
    public async Task RefreshAsync_WithExpiredSession_ShouldReturnUnauthorized()
    {
        var sessionId = _faker.Random.Guid().ToString("N");
        var expiredSession = new SessionRecord(sessionId, _faker.Random.Guid().ToString(), _faker.Random.Guid().ToString("N"),
            DateTime.UtcNow.AddMinutes(-5), _faker.Random.Guid().ToString("N"), _faker.Internet.UserAgent(), _faker.Internet.Ip());

        _sessionStore.Setup(s => s.GetSessionAsync(sessionId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expiredSession);

        var result = await _sut.RefreshAsync(
            new RequestContext(null, _faker.Internet.UserAgent(), _faker.Internet.Ip(), sessionId),
            CancellationToken.None);

        result.StatusCode.Should().Be(StatusCodes.Status401Unauthorized);
        result.Response.isSuccess.Should().BeFalse();
        result.Response.message.Should().Contain("Unauthorized");
        _sessionStore.Verify(s => s.GetSessionAsync(sessionId, It.IsAny<CancellationToken>()), Times.Once);
    }

    private static Mock<UserManager<User>> CreateUserManager()
    {
        var store = new Mock<IUserStore<User>>(MockBehavior.Loose);
        var options = new Mock<IOptions<IdentityOptions>>(MockBehavior.Loose);
        options.Setup(o => o.Value).Returns(new IdentityOptions());
        return new Mock<UserManager<User>>(MockBehavior.Loose, store.Object, options.Object,
            Mock.Of<IPasswordHasher<User>>(), Array.Empty<IUserValidator<User>>(), Array.Empty<IPasswordValidator<User>>(),
            Mock.Of<ILookupNormalizer>(), new IdentityErrorDescriber(), Mock.Of<IServiceProvider>(),
            Mock.Of<ILogger<UserManager<User>>>());
    }

    private static Mock<RoleManager<Role>> CreateRoleManager()
    {
        var store = new Mock<IRoleStore<Role>>(MockBehavior.Loose);
        return new Mock<RoleManager<Role>>(MockBehavior.Loose, store.Object, Array.Empty<IRoleValidator<Role>>(),
            Mock.Of<ILookupNormalizer>(), new IdentityErrorDescriber(), Mock.Of<ILogger<RoleManager<Role>>>());
    }

    private static Mock<SignInManager<User>> CreateSignInManager(UserManager<User> userManager)
    {
        var contextAccessor = new Mock<IHttpContextAccessor>(MockBehavior.Loose);
        var claimsFactory = new Mock<IUserClaimsPrincipalFactory<User>>(MockBehavior.Loose);
        var options = new Mock<IOptions<IdentityOptions>>(MockBehavior.Loose);
        options.Setup(o => o.Value).Returns(new IdentityOptions());
        return new Mock<SignInManager<User>>(MockBehavior.Loose, userManager, contextAccessor.Object,
            claimsFactory.Object, options.Object, Mock.Of<ILogger<SignInManager<User>>>(),
            Mock.Of<IAuthenticationSchemeProvider>(), Mock.Of<IUserConfirmation<User>>());
    }
}
