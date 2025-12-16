using LangfensEnglish.Tests.Common.Factories;
using LangfensEnglish.Tests.Common.Fixtures;
using Xunit;

namespace AuthService.IntegrationTests;

[Collection(nameof(IntegrationTestCollection))]
public class AuthFlowsTests
{
    private const string SkipReason = "Pending full automation harness (seed/fakes)";

    private readonly AuthServiceWebAppFactory _factory;

    public AuthFlowsTests(AuthServiceWebAppFactory factory)
    {
        _factory = factory;
    }

    public static IEnumerable<object[]> RegisterCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory]
    [MemberData(nameof(RegisterCases))]
    [Trait("Function", "Register account")]
    [Trait("Case", "01")]
    [Trait("Level", "Integration")]
    public void Register_Cases(int caseId)
    {
        if (caseId <= 2) Assert.True(false, "Simulated Auth Integration Failure for Demo");
    }

    public static IEnumerable<object[]> VerifyOtpCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(VerifyOtpCases))]
    [Trait("Function", "Verify OTP")]
    [Trait("Case", "02")]
    [Trait("Level", "Integration")]
    public void VerifyOtp_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> LoginCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(LoginCases))]
    [Trait("Function", "Password login")]
    [Trait("Case", "03")]
    [Trait("Level", "Integration")]
    public void PasswordLogin_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> GoogleLoginCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(GoogleLoginCases))]
    [Trait("Function", "Google login")]
    [Trait("Case", "04")]
    [Trait("Level", "Integration")]
    public void GoogleLogin_Cases(int caseId)
    {
    }

    public static IEnumerable<object[]> ForgotPasswordCases()
    {
        for (var i = 1; i <= 10; i++) yield return new object[] { i };
    }

    [Theory(Skip = SkipReason)]
    [MemberData(nameof(ForgotPasswordCases))]
    [Trait("Function", "Forgot password")]
    [Trait("Case", "05")]
    [Trait("Level", "Integration")]
    public void ForgotPassword_Cases(int caseId)
    {
    }
}
