using System.Net;
using System.Text.Json;
using email_service.Contracts;
using email_service.Features.Service;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using RichardSzalay.MockHttp;
using Shared.ExamDto.Contracts;
using Xunit;

namespace EmailService.UnitTests.Features.Service;

// Test class inheriting from EmailSender to override and inspect the final SendAsync call
public class TestableEmailSender : EmailSender
{
    public (string ToEmail, string Subject, string Html, string Plain)? LastCall { get; private set; }

    public TestableEmailSender(IOptions<SmtpOptions> options, IHttpClientFactory httpClientFactory, ILogger<string> logger)
        : base(options, httpClientFactory, logger)
    {
    }

    public override Task SendAsync(string toEmail, string subject, string html, string? plain = null, CancellationToken token = default)
    {
        LastCall = (toEmail, subject, html, plain);
        return Task.CompletedTask;
    }
}


public class EmailSender_Tests
{
    private readonly Mock<IHttpClientFactory> _mockHttpClientFactory;
    private readonly Mock<ILogger<string>> _mockLogger;
    private readonly IOptions<SmtpOptions> _options;

    public EmailSender_Tests()
    {
        _mockHttpClientFactory = new Mock<IHttpClientFactory>();
        _mockLogger = new Mock<ILogger<string>>();
        _options = Options.Create(new SmtpOptions
        {
            From = "noreply@langfens.com",
            Brand = "Langfens",
            Support = "support@langfens.com",
            VerifyUrlTemplate = "http://auth-service/internal/auth/verify-otp"
        });
    }

    public static IEnumerable<object[]> SendOtpAsync_TestCases()
    {
        // OE-003
        for (int i = 1; i <= 11; i++)
        {
            var email = $"user{i}@example.com";
            var otp = (100000 + i).ToString();
            var ttl = (60 * i);
            yield return new object[] { $"OE-003_Case{i:D2}", email, otp, (long)ttl };
        }
    }

    [Theory(DisplayName = "{0}")]
    [MemberData(nameof(SendOtpAsync_TestCases))]
    public async Task SendOtpAsync_Should_Build_And_Call_SendAsync_With_CorrectContent(string caseId, string email, string otp, long ttl)
    {
        // Arrange
        var sender = new TestableEmailSender(_options, _mockHttpClientFactory.Object, _mockLogger.Object);
        var expectedMinutes = Math.Max(1, ttl / 60);

        // Act
        await sender.SendOtpAsync(email, otp, ttl, CancellationToken.None);

        // Assert
        sender.LastCall.Should().NotBeNull();
        sender.LastCall!.Value.ToEmail.Should().Be(email);
        sender.LastCall!.Value.Subject.Should().Contain(otp);
        sender.LastCall!.Value.Html.Should().Contain(otp);
        sender.LastCall!.Value.Html.Should().Contain(email);
        sender.LastCall!.Value.Html.Should().Contain($"expire in <b>{expectedMinutes} minute(s)</b>");
    }

    public static IEnumerable<object[]> VerifyOtpAsync_TestCases()
    {
        var successBody = @"{""isSuccess"":true,""data"":true,""message"":""OK""}";
        var failureBody = @"{""isSuccess"":false,""data"":false,""message"":""Invalid""}";
        var malformedBody = @"{""isSuccess"":true,";

        // OE-004
        //                                caseId,                   email,          otp,      mockResponse,         mockStatusCode,      expectedResultStatus, expectJson
        yield return new object[] { "OE-004_Case01_Success",      "test@test.com", "123456", successBody,          HttpStatusCode.OK,            400,                  true };
        yield return new object[] { "OE-004_Case02_Failure",      "test@test.com", "654321", failureBody,          HttpStatusCode.BadRequest,    400,                  true };
        yield return new object[] { "OE-004_Case03_ServerError",  "test@test.com", "111111", "Internal Error",     HttpStatusCode.InternalServerError, 200,        false };
        yield return new object[] { "OE-004_Case04_MalformedJson","test@test.com", "222222", malformedBody,        HttpStatusCode.OK,            200,                  false };
        yield return new object[] { "OE-004_Case05_Unauthorized", "test@test.com", "333333", failureBody,          HttpStatusCode.Unauthorized,  200,                  true };
        // Fill to 11
        yield return new object[] { "OE-004_Case06_EmptyOtp",     "test@test.com", "",       successBody,          HttpStatusCode.OK,            200,                  true };
        yield return new object[] { "OE-004_Case07_EmptyEmail",   "",              "123456", successBody,          HttpStatusCode.OK,            500,                  true };
        yield return new object[] { "OE-004_Case08_NullOtp",      "test@test.com", null,     successBody,          HttpStatusCode.OK,            200,                  true };
        yield return new object[] { "OE-004_Case09_NullEmail",    null,            "123456", successBody,          HttpStatusCode.OK,            400,                  true };
        yield return new object[] { "OE-004_Case10_NotFound",     "test@test.com", "444444", failureBody,          HttpStatusCode.NotFound,      404,                  true };
        yield return new object[] { "OE-004_Case11_Conflict",     "test@test.com", "555555", failureBody,          HttpStatusCode.Conflict,      409,                  true };
    }


    [Theory(DisplayName = "{0}")]
    [MemberData(nameof(VerifyOtpAsync_TestCases))]
    public async Task VerifyOtpAsync_Should_Proxy_AuthServiceResult(string caseId, string email, string otp, string mockResponse, HttpStatusCode mockStatusCode, int expectedResultStatus, bool expectJson)
    {
        // Arrange
        var mockHttp = new MockHttpMessageHandler();
        mockHttp.When("http://auth-service/internal/auth/verify-otp")
              .Respond(mockStatusCode, expectJson ? "application/json" : "text/plain", mockResponse);
        
        var client = new HttpClient(mockHttp);
        _mockHttpClientFactory.Setup(_ => _.CreateClient(It.IsAny<string>())).Returns(client);
        
        var sender = new EmailSender(_options, _mockHttpClientFactory.Object, _mockLogger.Object);

        // Act
        var result = await sender.VerifyOtpAsync(email, otp, CancellationToken.None);

        // Assert
        var httpResult = result.Should().BeAssignableTo<IStatusCodeHttpResult>().Subject;
        httpResult.StatusCode.Should().Be(expectedResultStatus);

        if (expectJson)
        {
            var jsonResult = httpResult.Should().BeAssignableTo<IValueHttpResult>().Subject;
            var apiResult = jsonResult.Value.Should().BeAssignableTo<ApiResultDto>().Subject;
            var originalApiResult = JsonSerializer.Deserialize<ApiResultDto>(mockResponse, new JsonSerializerOptions(JsonSerializerDefaults.Web));
            apiResult.isSuccess.Should().Be(originalApiResult.isSuccess);
        }
        else
        {
            var contentResult = httpResult.Should().BeAssignableTo<IContentTypeHttpResult>().Subject;
            contentResult.ContentType.Should().Contain("text/plain");
        }
    }
}