using System.Net.WebSockets;
using System.Text;
using speaking_service.Features.Helper;
using Whisper.net;

namespace speaking_service.Features.Services;



public interface IWhisperService
{
    Task<IResult> Transcript(IFormFile request, WhisperProcessor processor);
    Task HandleWebsocketAsync(HttpContext context, WhisperProcessor processor, CancellationToken token);
    
}
public class WhisperService : IWhisperService
{
    
    public async Task<IResult> Transcript(IFormFile request, WhisperProcessor processor)
    {
        var tempInputPath = Path.GetTempFileName();
        string? tempNormalizedPath = null;
        try
        {
            await using (var fs = File.Create(tempInputPath))
            {
                await request.CopyToAsync(fs);
            }

            tempNormalizedPath = await AudioNormalizer.NormalizeTo16KWavAsync(tempInputPath);
            await using var wavStream = File.OpenRead(tempNormalizedPath);
            wavStream.Position = 0;
            var textBuilder = new StringBuilder();

            await foreach (var segment in processor.ProcessAsync(wavStream))
            {
                textBuilder.Append(segment.Text);
            }

            return Results.Ok(new { transcript = textBuilder.ToString() });
        }
        finally
        {
            if (!string.IsNullOrEmpty(tempNormalizedPath) && File.Exists(tempNormalizedPath)) File.Delete(tempNormalizedPath);
            if (!string.IsNullOrEmpty(tempInputPath) && File.Exists(tempInputPath)) File.Delete(tempInputPath);
        }
    }

    public async Task HandleWebsocketAsync(HttpContext context, WhisperProcessor processor, CancellationToken token)
    {
        if (!context.WebSockets.IsWebSocketRequest)
        {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            return;
        }

        using var webSocket = await context.WebSockets.AcceptWebSocketAsync();
        var buffer = new byte[1024 * 64];

        while (webSocket.State == WebSocketState.Open && !token.IsCancellationRequested)
        {
            WebSocketReceiveResult result;
            await using var memoryStream = new MemoryStream();
            try
            {
                do
                {
                    result = await webSocket.ReceiveAsync(buffer, token);

                    if (result.MessageType == WebSocketMessageType.Close)
                    {
                        await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closed connection", token);
                        return;
                    }

                    if (result.MessageType != WebSocketMessageType.Binary)
                    {
                        break;
                    }

                    if (result.Count > 0)
                    {
                        memoryStream.Write(buffer, 0, result.Count);
                    }

                } while (!result.EndOfMessage);

                if (result.MessageType != WebSocketMessageType.Binary || memoryStream.Length == 0)
                {
                    continue;
                }

                var chunkByte = memoryStream.ToArray();
                try
                {
                    var text = await TranscribeChunkAsync(chunkByte, processor, token);

                    if (!string.IsNullOrEmpty(text))
                    {
                        var msgBytes = Encoding.UTF8.GetBytes(text);
                        await webSocket.SendAsync(msgBytes, WebSocketMessageType.Text, true, token);
                    }
                }
                catch (Exception e)
                {
                    var errorBytes = Encoding.UTF8.GetBytes("[error] " + e.Message);
                    await webSocket.SendAsync(errorBytes, WebSocketMessageType.Text, true, token);
                }
            }
            catch (WebSocketException)
            {
                break; 
            }
        }
    }

    private async Task<string> TranscribeChunkAsync(byte[] data, WhisperProcessor processor, CancellationToken token)
    {
        var tempInputPath = Path.GetTempFileName();
        try
        {
            await File.WriteAllBytesAsync(tempInputPath, data, token);
            var tempNormalizedPath = await AudioNormalizer.NormalizeTo16KWavAsync(tempInputPath, token);
            await using var wavStream = File.OpenRead(tempNormalizedPath);
            var sb = new StringBuilder();
            await foreach (var segment in processor.ProcessAsync(wavStream, token))
            {
                sb.Append(segment.Text);
            }

            return sb.ToString();
        }
        finally
        {
            if (!string.IsNullOrEmpty(tempInputPath) && File.Exists(tempInputPath)) File.Delete(tempInputPath);
        }
    }

    

  

}