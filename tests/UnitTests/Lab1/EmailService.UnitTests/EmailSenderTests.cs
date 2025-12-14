using System;
using System.Net;
using System.Net.Http;
using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using email_service.Contracts;
using email_service.Features.Service;
using Shared.ExamDto.Contracts;
using Xunit;
using TestSupport;
using Microsoft.AspNetCore.Http.HttpResults;

namespace EmailService.UnitTests;

public class EmailSenderTests
{
    private readonly Faker _faker = new();
    private readonly Mock<IHttpClientFactory> _httpFactory = new(MockBehavior.Strict);
    private readonly Mock<ILogger<string>> _logger = new(MockBehavior.Loose);

    private IOptions<SmtpOptions> CreateOptions(string? verifyUrl = "https://auth/verify")
    {
        return Options.Create(new SmtpOptions
        {
            Host = "smtp.example.com",
            Port = 587,
            From = _faker.Internet.Email(),
            User = _faker.Internet.Email(),
            Pass = _faker.Internet.Password(),
            VerifyUrlTemplate = verifyUrl,
            RedirectUrl = "https://app/verify",
            Brand = "BrandX",
            Support = _faker.Internet.Email()
        });
    }

    [Fact]
    public async Task VerifyOtpAsync_WhenBackendReturnsJson_ShouldReturnParsedResult()
    {
        var response = new ApiResultDto(true, "ok", new { token = _faker.Random.Guid() });
        var handler = new FakeHandler(new HttpResponseMessage(HttpStatusCode.OK)
        {
            Content = new StringContent(JsonSerializer.Serialize(response), System.Text.Encoding.UTF8, "application/json")
        });
        var client = new HttpClient(handler) { BaseAddress = new Uri("https://auth") };
        _httpFactory.Setup(f => f.CreateClient("auth-confirm")).Returns(client);
        var sender = new EmailSender(CreateOptions(), _httpFactory.Object, _logger.Object);

        var result = await sender.VerifyOtpAsync("user@example.com", "123456", CancellationToken.None);

        var (status, payload) = TestSupport.ResultAssert.Api(result);
        status.Should().Be(StatusCodes.Status200OK);
        payload.isSuccess.Should().BeTrue();
        handler.LastRequest.Should().NotBeNull();
        handler.LastRequest!.RequestUri!.Query.Should().Contain("email=user@example.com");
        handler.LastRequest.RequestUri.Query.Should().Contain("otp=123456");
    }

    [Fact]
    public async Task VerifyOtpAsync_WhenBackendReturnsPlain_ShouldReturnContent()
    {
        var body = _faker.Lorem.Sentence();
        var handler = new FakeHandler(new HttpResponseMessage(HttpStatusCode.BadRequest)
        {
            Content = new StringContent(body, System.Text.Encoding.UTF8, "text/plain")
        });
        var client = new HttpClient(handler) { BaseAddress = new Uri("https://auth") };
        _httpFactory.Setup(f => f.CreateClient("auth-confirm")).Returns(client);
        var sender = new EmailSender(CreateOptions(), _httpFactory.Object, _logger.Object);

        var result = await sender.VerifyOtpAsync("user@example.com", "999999", CancellationToken.None);

        var contentResult = Assert.IsType<ContentHttpResult>(result);
        contentResult.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
    }

    [Fact]
    public void VerifyOtpAsync_WhenTemplateMissing_ShouldThrow()
    {
        var sender = new EmailSender(CreateOptions(verifyUrl: null), _httpFactory.Object, _logger.Object);

        Func<Task> act = async () => await sender.VerifyOtpAsync("user@example.com", "123", CancellationToken.None);

        act.Should().ThrowAsync<InvalidOperationException>();
    }

    private sealed class FakeHandler : HttpMessageHandler
    {
        private readonly HttpResponseMessage _response;
        public HttpRequestMessage? LastRequest { get; private set; }

        public FakeHandler(HttpResponseMessage response)
        {
            _response = response;
        }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            LastRequest = request;
            return Task.FromResult(_response);
        }
    }
}
