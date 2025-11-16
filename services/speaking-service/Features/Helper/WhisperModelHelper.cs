using Whisper.net.Ggml;

namespace speaking_service.Features.Helper;

public static class WhisperModelHelper
{

    public static async Task<string> EnsureModelDownloadedAsync()
    {

        var modelDir = Path.Combine(AppContext.BaseDirectory, "Models");
        Directory.CreateDirectory(modelDir);
        var modelPath = Path.Combine(modelDir, "ggml-tiny.en.bin");
        if (!File.Exists(modelPath))
        {
            await using var modelStream = await WhisperGgmlDownloader.Default.GetGgmlModelAsync(GgmlType.TinyEn);
            await using var fileWriter = File.OpenWrite(modelPath);
            Console.WriteLine($"Downloading {modelPath}");
            await modelStream.CopyToAsync(fileWriter);
        }

        return modelPath;
    }
}

