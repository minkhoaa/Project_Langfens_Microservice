using exam_service.Features.ReadingPaper;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace exam_service.Tests;

public sealed class ReadingPaperAiClientConfigurationTests
{
    [Fact]
    public void ResolveInternalApiKey_ReadsHierarchicalEnvironmentConfigurationKey()
    {
        const string expected = "test-internal-service-key";
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["EXAMSERVICE:INTERNAL:API:KEY"] = expected
            })
            .Build();

        Assert.Equal(expected, ReadingPaperAiClientConfiguration.ResolveInternalApiKey(configuration));
    }

    [Fact]
    public void ResolveInternalApiKey_PreservesLegacyFallback()
    {
        const string expected = "legacy-internal-service-key";
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["INTERNAL_API_KEY"] = expected
            })
            .Build();

        Assert.Equal(expected, ReadingPaperAiClientConfiguration.ResolveInternalApiKey(configuration));
    }

    [Fact]
    public void ResolveInternalApiKey_ReadsAspireSecretParameterKey()
    {
        const string expected = "aspire-secret-parameter-key";
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Parameters:internal-api-key"] = expected
            })
            .Build();

        Assert.Equal(expected, ReadingPaperAiClientConfiguration.ResolveInternalApiKey(configuration));
    }

    [Fact]
    public void ResolveInternalApiKey_ReadsDoubleUnderscoreKey()
    {
        const string expected = "double-underscore-env-key";
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["EXAMSERVICE__INTERNAL__API__KEY"] = expected
            })
            .Build();

        Assert.Equal(expected, ReadingPaperAiClientConfiguration.ResolveInternalApiKey(configuration));
    }

    [Fact]
    public void ResolveInternalApiKey_ReturnsEmptyWhenUnconfigured()
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>())
            .Build();

        Assert.Equal(string.Empty, ReadingPaperAiClientConfiguration.ResolveInternalApiKey(configuration));
    }

    [Fact]
    public async Task ReadingPaperAiClient_AttachesInternalApiKeyHeaderWhenConfigured()
    {
        const string expectedKey = "test-configured-secret-key";
        HttpRequestMessage? capturedRequest = null;

        var handler = new TestCaptureHandler(req => capturedRequest = req);
        var httpClient = new HttpClient(handler)
        {
            BaseAddress = new Uri("http://localhost:8080/")
        };
        httpClient.DefaultRequestHeaders.Add(CheckpointService.InternalApiKeyHeader, expectedKey);

        var aiClient = new ReadingPaperAiClient(httpClient);

        // Act: Make a fetch call that will be captured
        try
        {
            await aiClient.FetchSourceAsync("PMC12345678", CancellationToken.None);
        }
        catch
        {
            // Expected if mock response isn't full JSON
        }

        Assert.NotNull(capturedRequest);
        Assert.True(capturedRequest.Headers.Contains(CheckpointService.InternalApiKeyHeader));
        Assert.Equal(expectedKey, capturedRequest.Headers.GetValues(CheckpointService.InternalApiKeyHeader).First());
    }

    [Fact]
    public async Task ReadingPaperAiClient_OmitsInternalApiKeyHeaderWhenUnconfigured()
    {
        HttpRequestMessage? capturedRequest = null;

        var handler = new TestCaptureHandler(req => capturedRequest = req);
        var httpClient = new HttpClient(handler)
        {
            BaseAddress = new Uri("http://localhost:8080/")
        };
        // No header added

        var aiClient = new ReadingPaperAiClient(httpClient);

        try
        {
            await aiClient.FetchSourceAsync("PMC12345678", CancellationToken.None);
        }
        catch
        {
            // Expected
        }

        Assert.NotNull(capturedRequest);
        Assert.False(capturedRequest.Headers.Contains(CheckpointService.InternalApiKeyHeader));
    }

    private sealed class TestCaptureHandler(Action<HttpRequestMessage> capture) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            capture(request);
            return Task.FromResult(new HttpResponseMessage(System.Net.HttpStatusCode.OK)
            {
                Content = new StringContent("{\"pmcid\":\"PMC12345678\",\"title\":\"Test Title\",\"url\":\"https://example.com\",\"license\":\"CC-BY-4.0\",\"wordCount\":700}")
            });
        }
    }

    [Fact]
    public void ComputeHash_MatchesExpected()
    {
        var pol = PinnedExecutionPolicy.CreateDefault("minimax");
        Assert.Equal("4b35e559aa6531033953d813e6deeaa5465c66c4107b4574c0ed29972c7fb1d2", pol.ComputeHash());
    }
}
