using Microsoft.AspNetCore.Mvc;
using speaking_service.Features.Services;
using Whisper.net;

namespace speaking_service.Features.Handler;

public static class WhisperHandler
{
    [DisableRequestSizeLimit]
    public static Task<IResult> TranscriptHandler(
        IFormFile request, WhisperProcessor processor, IWhisperService service)
        => service.Transcript(request, processor);

    public static Task HandleWebsocketAsync(
        HttpContext context, WhisperProcessor processor,
        CancellationToken token, IWhisperService service)
        => service.HandleWebsocketAsync(context, processor, token);

}