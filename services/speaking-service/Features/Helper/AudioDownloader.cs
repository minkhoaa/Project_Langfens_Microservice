using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CloudinaryDotNet.Core;
using MassTransit;
using Microsoft.VisualBasic;

namespace speaking_service.Features.Helper
{
    public interface IAudioDownloader
    {
        Task<IFormFile> GetAudioStreamAsync(string url, CancellationToken token, string fileName = "audio/webm");
    }
    public class AudioDownloader : IAudioDownloader
    {
        private readonly HttpClient _client;
        private readonly ILogger<AudioDownloader> _logger;
        public AudioDownloader(HttpClient client, ILogger<AudioDownloader> logger)
        {
            _client = client;
            _logger = logger;
        }

        public async Task<IFormFile> GetAudioStreamAsync(string url, CancellationToken token, string fileName = "audio/webm")
        {
            var audio = await _client.GetAsync(url, token);
            _logger.LogInformation($"Downloading audio from {url}");
            audio.EnsureSuccessStatusCode();
            var memoryStream = new MemoryStream();
            await audio.Content.CopyToAsync(memoryStream, token);
            memoryStream.Position = 0;
            // convert into FormFile
            var contentType = audio.Content.Headers.ContentType?.ToString() ?? "audio/webm";
            var formFile = new FormFile(memoryStream, 0, memoryStream.Length, "file", fileName)
            {
                Headers = new HeaderDictionary(),
                ContentType = contentType
            };
            _logger.LogInformation("Download done");

            return formFile;
        }
    }
}