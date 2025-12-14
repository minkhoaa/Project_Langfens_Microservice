using System;
using System.Net.WebSockets;
using System.Runtime.Serialization;
using System.Threading;
using System.Threading.Tasks;
using Bogus;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Features;
using Moq;
using speaking_service.Features.Services.Helper;
using Whisper.net;
using Xunit;

namespace speaking_service.Features.Services.Helper.UnitTests;

public class WhisperServiceTests
{
    private readonly Faker _faker = new();
    private readonly Mock<IHttpContextAccessor> _httpContextAccessor = new(MockBehavior.Strict);
    private readonly WhisperFactory _factory;

    public WhisperServiceTests()
    {
        // WhisperFactory has no public constructor we can use; this bypasses ctor as it is unused in tested paths.
        _factory = (WhisperFactory)FormatterServices.GetUninitializedObject(typeof(WhisperFactory));
    }

    [Fact]
    public async Task HandleWebsocketAsync_WhenNotWebsocketRequest_ShouldReturnBadRequest()
    {
        var context = new DefaultHttpContext();
        var service = new WhisperService(_httpContextAccessor.Object, _factory);

        await service.HandleWebsocketAsync(context, null!, CancellationToken.None);

        context.Response.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
    }

    [Fact]
    public async Task HandleWebsocketAsync_WithCancelledToken_ShouldNotProcessMessages()
    {
        var context = new DefaultHttpContext();
        context.Request.Headers.UserAgent = _faker.Internet.UserAgent();
        var fakeSocket = new FakeWebSocket();
        var feature = new FakeWebSocketFeature(fakeSocket);
        context.Features.Set<IHttpWebSocketFeature>(feature);
        var service = new WhisperService(_httpContextAccessor.Object, _factory);
        var cancelled = new CancellationToken(true);

        await service.HandleWebsocketAsync(context, null!, cancelled);

        fakeSocket.Accepted.Should().BeTrue();
        fakeSocket.ReceiveCalls.Should().Be(0);
        fakeSocket.SendCalls.Should().Be(0);
    }

    private sealed class FakeWebSocketFeature : IHttpWebSocketFeature
    {
        private readonly FakeWebSocket _socket;
        public FakeWebSocketFeature(FakeWebSocket socket)
        {
            _socket = socket;
        }

        public bool IsWebSocketRequest => true;

        public Task<WebSocket> AcceptAsync(WebSocketAcceptContext context)
        {
            _socket.Accepted = true;
            return Task.FromResult<WebSocket>(_socket);
        }
    }

    private sealed class FakeWebSocket : WebSocket
    {
        public bool Accepted { get; set; }
        public int SendCalls { get; private set; }
        public int ReceiveCalls { get; private set; }
        private WebSocketState _state = WebSocketState.Open;

        public override WebSocketCloseStatus? CloseStatus => WebSocketCloseStatus.NormalClosure;
        public override string? CloseStatusDescription => null;
        public override WebSocketState State => _state;
        public override string? SubProtocol => null;

        public override void Abort() => _state = WebSocketState.Aborted;

        public override Task CloseAsync(WebSocketCloseStatus closeStatus, string? statusDescription, CancellationToken cancellationToken)
        {
            _state = WebSocketState.Closed;
            return Task.CompletedTask;
        }

        public override Task CloseOutputAsync(WebSocketCloseStatus closeStatus, string? statusDescription, CancellationToken cancellationToken) =>
            CloseAsync(closeStatus, statusDescription, cancellationToken);

        public override void Dispose() => _state = WebSocketState.Closed;

        public override Task<WebSocketReceiveResult> ReceiveAsync(ArraySegment<byte> buffer, CancellationToken cancellationToken)
        {
            ReceiveCalls++;
            _state = WebSocketState.CloseSent;
            return Task.FromResult(new WebSocketReceiveResult(0, WebSocketMessageType.Close, true));
        }

        public override Task SendAsync(ArraySegment<byte> buffer, WebSocketMessageType messageType, bool endOfMessage, CancellationToken cancellationToken)
        {
            SendCalls++;
            return Task.CompletedTask;
        }
    }
}
