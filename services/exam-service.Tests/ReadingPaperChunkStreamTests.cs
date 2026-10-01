using System.Net;
using System.Text;
using System.Text.Json;
using exam_service.Features.ReadingPaper;
using Xunit;

namespace exam_service.Tests;

public class ReadingPaperChunkStreamTests
{
    private sealed class ChunkedStream(List<byte[]> chunks) : Stream
    {
        private int _chunkIndex;
        private int _chunkOffset;

        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => chunks.Sum(c => c.Length);
        public override long Position
        {
            get => throw new NotSupportedException();
            set => throw new NotSupportedException();
        }

        public override void Flush() { }

        public override int Read(byte[] buffer, int offset, int count)
        {
            if (_chunkIndex >= chunks.Count) return 0;
            var currentChunk = chunks[_chunkIndex];
            var available = currentChunk.Length - _chunkOffset;
            var toRead = Math.Min(available, count);
            Array.Copy(currentChunk, _chunkOffset, buffer, offset, toRead);
            _chunkOffset += toRead;
            if (_chunkOffset >= currentChunk.Length)
            {
                _chunkIndex++;
                _chunkOffset = 0;
            }
            return toRead;
        }

        public override Task<int> ReadAsync(byte[] buffer, int offset, int count, CancellationToken ct)
            => Task.FromResult(Read(buffer, offset, count));

        public override ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken ct = default)
        {
            if (_chunkIndex >= chunks.Count) return ValueTask.FromResult(0);
            var currentChunk = chunks[_chunkIndex];
            var available = currentChunk.Length - _chunkOffset;
            var toRead = Math.Min(available, buffer.Length);
            currentChunk.AsSpan(_chunkOffset, toRead).CopyTo(buffer.Span);
            _chunkOffset += toRead;
            if (_chunkOffset >= currentChunk.Length)
            {
                _chunkIndex++;
                _chunkOffset = 0;
            }
            return ValueTask.FromResult(toRead);
        }

        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) => throw new NotSupportedException();
    }

    private sealed class ChunkedHttpHandler(Func<Stream> streamFactory, HttpStatusCode status = HttpStatusCode.OK, string mediaType = "application/x-ndjson")
        : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
        {
            var content = new StreamContent(streamFactory());
            content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(mediaType);
            var response = new HttpResponseMessage(status) { Content = content };
            return Task.FromResult(response);
        }
    }

    [Fact]
    public async Task ParseNdjson_ReconstructsEvents_WhenChunksSplitMidUtf8AndMidJson()
    {
        // 1. Prepare valid section
        var expectedSection = ReadingPaperTests.Paper()[0];
        var serializedSection = JsonSerializer.Serialize(expectedSection, ReadingPaperRules.Json);

        // 2. Prepare chunk with mid-UTF8 split:
        // Character: "“" (U+201C, UTF-8: 0xE2 0x80 0x9C)
        var utf8Lead = new byte[] { 0xE2, 0x80 };
        var utf8Trail = new byte[] { 0x9C };

        var prefixBytes = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Evidence: ");
        var suffixBytes = Encoding.UTF8.GetBytes("species in forest\"}\n");

        var chunk1 = prefixBytes.Concat(utf8Lead).ToArray();
        var chunk2 = utf8Trail.Concat(suffixBytes).ToArray();

        // 3. Prepare chunk with mid-JSON split:
        var line2Part1 = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Pass");
        var line2Part2 = Encoding.UTF8.GetBytes("age 1 accepted\"}\n");

        // 4. Terminal event
        var terminalLine = Encoding.UTF8.GetBytes($"{{\"type\":\"result\",\"section\":{serializedSection}}}\n");

        var chunks = new List<byte[]> { chunk1, chunk2, line2Part1, line2Part2, terminalLine };

        var handler = new ChunkedHttpHandler(() => new ChunkedStream(chunks));
        var http = new HttpClient(handler) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var loggedMessages = new List<string>();
        var result = await client.GenerateSectionAsync(
            "marine biology",
            1,
            expectedSection.Source,
            (level, msg) => { loggedMessages.Add(msg); return Task.CompletedTask; },
            CancellationToken.None
        );

        Assert.NotNull(result);
        Assert.Equal(expectedSection.Title, result.Title);
        Assert.Equal(expectedSection.Passage, result.Passage);
        Assert.Equal(2, result.Groups.Count);
        Assert.Equal(2, loggedMessages.Count);
        Assert.Contains("Evidence: “species in forest", loggedMessages[0]);
        Assert.Equal("Passage 1 accepted", loggedMessages[1]);
    }

    [Fact]
    public async Task ParseNdjson_ThrowsJsonException_WhenEofReachedWithoutTerminalEvent()
    {
        var line1 = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Working...\"}\n");
        var line2 = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Almost done...\"}\n");
        var chunks = new List<byte[]> { line1, line2 };

        var handler = new ChunkedHttpHandler(() => new ChunkedStream(chunks));
        var http = new HttpClient(handler) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var ex = await Assert.ThrowsAsync<JsonException>(() =>
            client.GenerateSectionAsync("topic", 1, ReadingPaperTests.Paper()[0].Source, null, CancellationToken.None));

        Assert.Contains("closed the progress stream without a generated section", ex.Message);
    }

    [Fact]
    public async Task ParseNdjson_ThrowsReadingSourceUnavailableException_WhenTerminalErrorIs422()
    {
        var line1 = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Starting...\"}\n");
        var line2 = Encoding.UTF8.GetBytes("{\"type\":\"error\",\"httpStatus\":422,\"message\":\"Source content is too short (599 words)\",\"traceback\":\"\"}\n");
        var chunks = new List<byte[]> { line1, line2 };

        var handler = new ChunkedHttpHandler(() => new ChunkedStream(chunks));
        var http = new HttpClient(handler) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var ex = await Assert.ThrowsAsync<ReadingSourceUnavailableException>(() =>
            client.GenerateSectionAsync("topic", 1, ReadingPaperTests.Paper()[0].Source, null, CancellationToken.None));

        Assert.Contains("Source content is too short", ex.Message);
    }

    [Fact]
    public async Task ParseNdjson_ThrowsHttpRequestException_WhenTerminalErrorIs502()
    {
        var line1 = Encoding.UTF8.GetBytes("{\"type\":\"log\",\"level\":\"Information\",\"message\":\"Starting...\"}\n");
        var line2 = Encoding.UTF8.GetBytes("{\"type\":\"error\",\"httpStatus\":502,\"message\":\"Model returned empty response\",\"traceback\":\"Traceback...\"}\n");
        var chunks = new List<byte[]> { line1, line2 };

        var handler = new ChunkedHttpHandler(() => new ChunkedStream(chunks));
        var http = new HttpClient(handler) { BaseAddress = new Uri("http://localhost:8080/") };
        var client = new ReadingPaperAiClient(http);

        var ex = await Assert.ThrowsAsync<HttpRequestException>(() =>
            client.GenerateSectionAsync("topic", 1, ReadingPaperTests.Paper()[0].Source, null, CancellationToken.None));

        Assert.Contains("Model returned empty response", ex.Message);
    }
}
