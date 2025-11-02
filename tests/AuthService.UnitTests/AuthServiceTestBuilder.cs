using AuthService.UnitTests.Helpers;

namespace AuthService.UnitTests;

internal sealed class AuthServiceTestBuilder
{
    public Mock<UserManager<User>> UserManager { get; } = IdentityMocks.CreateUserManager();
    public Mock<SignInManager<User>> SignInManager { get; }
    public Mock<IJwtTokenFactory> JwtTokenFactory { get; } = new();
    public Mock<IEmailValidator> EmailValidator { get; } = new();
    public Mock<ISessionRepository> SessionRepository { get; } = new();
    public Mock<ISessionStore> SessionStore { get; } = new();
    public Mock<IGoogleTokenVerifier> GoogleTokenVerifier { get; } = new();
    public Mock<IOtpStore> OtpStore { get; } = new();
    public Mock<IPublishEndpoint> PublishEndpoint { get; } = new();
    public Mock<ILogger<string>> Logger { get; } = new();
    public Mock<IOtpGenerator> OtpGenerator { get; } = new();
    public IOptions<JwtSettings> JwtSettings { get; } = Options.Create(new JwtSettings
    {
        Issuer = "test-issuer",
        Audience = "test-audience",
        SignKey = "0123456789abcdef0123456789abcdef",
        RsaPrivateKeyPem = "-----BEGIN PRIVATE KEY-----\nMIIBOgIBAAJBfakekey\n-----END PRIVATE KEY-----",
        KeyId = "test-key",
        AccessTokenLifetimeSeconds = 900
    });

    public AuthServiceTestBuilder()
    {
        SignInManager = IdentityMocks.CreateSignInManager(UserManager.Object);
        SessionRepository.Setup(r => r.UpsertAsync(It.IsAny<SessionEntity>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((SessionEntity entity, CancellationToken _) => entity);
        SessionRepository.Setup(r => r.SaveChangesAsync(It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        SessionStore.Setup(s => s.StoreSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        SessionStore.Setup(s => s.SetDeviceSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        SessionStore.Setup(s => s.EnsureSessionLimitAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        SessionStore.Setup(s => s.RefreshSessionTtlAsync(It.IsAny<string>(), It.IsAny<TimeSpan>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        SessionStore.Setup(s => s.RemoveSessionAsync(It.IsAny<SessionRecord>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
    }

    public auth_service.Application.Auth.AuthService Build() => new(
        UserManager.Object,
        SignInManager.Object,
        JwtTokenFactory.Object,
        EmailValidator.Object,
        SessionRepository.Object,
        SessionStore.Object,
        GoogleTokenVerifier.Object,
        OtpStore.Object,
        PublishEndpoint.Object,
        Logger.Object,
        OtpGenerator.Object,
        JwtSettings);
}
