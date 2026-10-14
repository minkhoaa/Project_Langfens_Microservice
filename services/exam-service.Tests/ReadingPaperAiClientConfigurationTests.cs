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
}
