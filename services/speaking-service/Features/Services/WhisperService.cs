using System.Text;
using speaking_service.Features.Helper;
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

            return Results.Ok(textBuilder.ToString());
        }
        finally
        {
            TryDelete(tempNormalizedPath);
            TryDelete(tempInputPath);
        }
    }
    
    private static void TryDelete(string? path)
    {
        try
        {
            if (!string.IsNullOrEmpty(path) && File.Exists(path))
            {
                File.Delete(path);
            }
        }
        catch
        {
            // ignore
        }
    }

}