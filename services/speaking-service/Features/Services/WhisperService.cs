using System.Text;
using Whisper.net;

namespace speaking_service.Features.Services;



public interface IWhisperService
{
    Task<IResult> Transcript(IFormFile request, WhisperProcessor processor);
}
public class WhisperService : IWhisperService
{
    public async Task<IResult> Transcript(IFormFile request, WhisperProcessor processor)
    {
        await using var memoryStream = new MemoryStream();
        await request.CopyToAsync(memoryStream);
        memoryStream.Position = 0;
        var textBuilder = new StringBuilder();

        await foreach (var segment in processor.ProcessAsync(memoryStream))
        {
            textBuilder.Append(segment.Text);
        }

        return Results.Ok(textBuilder.ToString());
    }
}