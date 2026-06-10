using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Shared.PublicContracts.Contracts.Ai;
using Xunit;
using attempt_service.Features.Helpers.Reading;

namespace attempt_service.Tests.Helpers.Reading;

public class ReadingGraderTests
{
    [Fact]
    public async Task Returns_envelope_when_client_succeeds()
    {
        var expected = new RagFeedbackEnvelope(
            "r1", "reading", 6.5,
            new[] { new CriterionScore("comprehension", 6.5, "ok") },
            System.Array.Empty<Evidence>(),
            System.Array.Empty<Suggestion>());
        var client = new Mock<IReadingExplainerClient>();
        client.Setup(c => c.ExplainAsync(
            "r1", "passage", "Q", "MCQ",
            It.IsAny<System.Collections.Generic.IReadOnlyList<string>>(),
            "A", "B", It.IsAny<CancellationToken>()))
            .ReturnsAsync(expected);

        var grader = new ReadingGrader(client.Object, NullLogger<ReadingGrader>.Instance);
        var env = await grader.AugmentAsync(
            "r1", "passage", "Q", "MCQ",
            new[] { "A", "B" }, "A", "B");

        Assert.NotNull(env);
        Assert.Equal("reading", env!.Domain);
    }

    [Fact]
    public async Task Returns_null_when_client_throws()
    {
        var client = new Mock<IReadingExplainerClient>();
        client.Setup(c => c.ExplainAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<System.Collections.Generic.IReadOnlyList<string>>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new System.Net.Http.HttpRequestException("boom"));

        var grader = new ReadingGrader(client.Object, NullLogger<ReadingGrader>.Instance);
        var env = await grader.AugmentAsync(
            "r1", "passage", "Q", "MCQ",
            new[] { "A", "B" }, "A", "B");

        Assert.Null(env);
    }
}
