using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Xunit;
using attempt_service.Features.Helpers.Listening;
using attempt_service.Features.Helpers.RagExplainer;

namespace attempt_service.Tests.Helpers.Listening;

public class ListeningGraderTests
{
    [Fact]
    public async Task Returns_envelope_when_client_succeeds()
    {
        var expected = new RagFeedbackEnvelopeDto
        {
            ItemId = "l1",
            Domain = "listening",
            OverallBand = 7.0,
        };
        var json = JsonSerializer.Serialize(expected);
        var client = new Mock<IListeningExplainerClient>();
        client.Setup(c => c.ExplainAsync(
            "l1", "transcript", "Q", "MCQ",
            It.IsAny<System.Collections.Generic.IReadOnlyList<string>>(),
            "A", "B", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(json);

        var grader = new ListeningGrader(client.Object, NullLogger<ListeningGrader>.Instance);
        var envJson = await grader.AugmentAsync(
            "l1", "transcript", "Q", "MCQ",
            new[] { "A", "B" }, "A", "B", 1);

        Assert.NotNull(envJson);
        var env = JsonSerializer.Deserialize<RagFeedbackEnvelopeDto>(envJson!);
        Assert.NotNull(env);
        Assert.Equal("listening", env!.Domain);
    }

    [Fact]
    public async Task Returns_null_when_client_throws()
    {
        var client = new Mock<IListeningExplainerClient>();
        client.Setup(c => c.ExplainAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<System.Collections.Generic.IReadOnlyList<string>>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new System.Net.Http.HttpRequestException("boom"));

        var grader = new ListeningGrader(client.Object, NullLogger<ListeningGrader>.Instance);
        var envJson = await grader.AugmentAsync(
            "l1", "transcript", "Q", "MCQ",
            new[] { "A", "B" }, "A", "B", 1);

        Assert.Null(envJson);
    }
}
