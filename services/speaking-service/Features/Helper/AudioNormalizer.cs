using System.Diagnostics;

namespace speaking_service.Features.Helper;

public static class AudioNormalizer
{
    public static async Task<string> NormalizeTo16KWavAsync(
        string inputPath,
        CancellationToken token = default
    )
    {
        var outputPath = Path.ChangeExtension(Path.GetTempFileName(), ".wav");

        var args =
            $"-y -i \"{inputPath}\" "
            + "-ac 1 "
            + "-ar 16000 "
            + "-f wav "
            + "-acodec pcm_s16le "
            + $"\"{outputPath}\"";

        var psi = new ProcessStartInfo
        {
            FileName = "ffmpeg",
            Arguments = args,
            RedirectStandardError = true,
            RedirectStandardOutput = true,
            UseShellExecute = false,
            CreateNoWindow = true,
        };

        using var process = Process.Start(psi);
        if (process == null)
            throw new InvalidOperationException("Không chạy được ffmpeg.");

        var stderrTask = process.StandardError.ReadToEndAsync(token);

        await process.WaitForExitAsync(token);

        var stderr = await stderrTask;

        if (process.ExitCode != 0)
        {
            throw new Exception($"ffmpeg convert fail (exit {process.ExitCode}): {stderr}");
        }

        return outputPath;
    }
}
