using System.Net;
using RichardSzalay.MockHttp;

namespace LangfensEnglish.Tests.Common.Mocks;

public static class MockHttpMessageHandlerFactory
{
    public static MockHttpMessageHandler Create(string baseUrl, HttpStatusCode statusCode, string responseContent)
    {
        var mockHttp = new MockHttpMessageHandler();
        mockHttp.When($"{baseUrl}/*")
                .Respond(statusCode, "application/json", responseContent);
        return mockHttp;
    }

    public static MockHttpMessageHandler CreateForOtpVerification(string authServiceUrl, string email, string otp, bool success)
    {
        var mockHttp = new MockHttpMessageHandler();
        var responseMessage = success
            ? @"{ ""isSuccess"": true, ""data"": true }"
            : @"{ ""isSuccess"": false, ""error"": {""code"": ""InvalidOtp"", ""message"": ""OTP is invalid or expired.""} }";

        var expectedUrl = $"{authServiceUrl}/internal/auth/verify-otp";

        // We can be more specific with the request body if needed, but for now, we'll just match the URL.
        mockHttp.When(HttpMethod.Post, expectedUrl)
                .WithContent(@$"*""email"":""{email}""*""otp"":""{otp}""*") // Wildcard matching for the content
                .Respond("application/json", responseMessage);
                
        // Fallback for any other call to the same endpoint that doesn't match
        mockHttp.When(HttpMethod.Post, expectedUrl)
                .Respond(HttpStatusCode.BadRequest, "application/json", @"{ ""isSuccess"": false, ""error"": {""code"": ""MismatchInput"", ""message"": ""Input did not match expected test case.""} }");

        return mockHttp;
    }
}
