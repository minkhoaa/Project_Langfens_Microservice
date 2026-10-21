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
    public void ComputeHash_MatchesExpected()
    {
        var pol = PinnedExecutionPolicy.CreateDefault("minimax");
        Assert.Equal("4b35e559aa6531033953d813e6deeaa5465c66c4107b4574c0ed29972c7fb1d2", pol.ComputeHash());
    }
}
