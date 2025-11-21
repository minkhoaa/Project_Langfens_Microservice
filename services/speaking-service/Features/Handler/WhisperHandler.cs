using Microsoft.AspNetCore.Mvc;
using speaking_service.Features.Services;
using speaking_service.Features.Services.Helper;
using Whisper.net;

namespace speaking_service.Features.Handler;

public static class WhisperHandler
{
    [DisableRequestSizeLimit]
    public static Task<string> TranscriptHandler(
        IFormFile request, IWhisperService service)
        => service.Transcript(request);

    public static Task HandleWebsocketAsync(
        HttpContext context, WhisperProcessor processor,
        CancellationToken token, IWhisperService service)
        => service.HandleWebsocketAsync(context, processor, token);

}