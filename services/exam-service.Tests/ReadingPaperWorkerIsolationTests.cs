using Microsoft.Extensions.Configuration;
using Xunit;

namespace exam_service.Tests;

public sealed class ReadingPaperWorkerIsolationTests
{
    [Theory]
    [InlineData("true", null, true)]
    [InlineData("false", null, false)]
    [InlineData(null, "true", true)]
    [InlineData(null, "false", false)]
    public void WorkerEnabled_EvaluatesCorrectly(string? configVal, string? envVal, bool expected)
    {
        var configBuilder = new ConfigurationBuilder();
        if (configVal != null)
        {
            configBuilder.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ReadingPaper:WorkerEnabled"] = configVal
            });
        }
        var config = configBuilder.Build();

        var originalEnv = Environment.GetEnvironmentVariable("READING_PAPER_WORKER_ENABLED");
        try
        {
            if (envVal != null)
            {
                Environment.SetEnvironmentVariable("READING_PAPER_WORKER_ENABLED", envVal);
            }
            else
            {
                Environment.SetEnvironmentVariable("READING_PAPER_WORKER_ENABLED", null);
            }

            var workerEnabled = config.GetValue<bool>("ReadingPaper:WorkerEnabled", true)
                && Environment.GetEnvironmentVariable("READING_PAPER_WORKER_ENABLED") != "false";

            Assert.Equal(expected, workerEnabled);
        }
        finally
        {
            Environment.SetEnvironmentVariable("READING_PAPER_WORKER_ENABLED", originalEnv);
        }
    }

    [Fact]
    public void WorkerEnabled_DefaultsToTrueWhenUnconfigured()
    {
        var config = new ConfigurationBuilder().Build();
        var originalEnv = Environment.GetEnvironmentVariable("READING_PAPER_WORKER_ENABLED");
        try
        {
            Environment.SetEnvironmentVariable("READING_PAPER_WORKER_ENABLED", null);
            var workerEnabled = config.GetValue<bool>("ReadingPaper:WorkerEnabled", true)
                && Environment.GetEnvironmentVariable("READING_PAPER_WORKER_ENABLED") != "false";

            Assert.True(workerEnabled);
        }
        finally
        {
            Environment.SetEnvironmentVariable("READING_PAPER_WORKER_ENABLED", originalEnv);
        }
    }
}
