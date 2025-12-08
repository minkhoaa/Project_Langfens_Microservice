using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Protobuf.Reflection;
using Microsoft.Extensions.Primitives;
using Shared.ExamDto.Contracts.Speaking;

namespace speaking_service.Features.Services.User
{
    public interface ICloudinaryService
    {
        Task<IResult> Upload(IFormFile formFile);

    }
    public class CloudinaryService : ICloudinaryService
    {
        private readonly Cloudinary _cloudinary;
        public CloudinaryService(Cloudinary cloudinary)
        {
            _cloudinary = cloudinary;
        }

        public async Task<IResult> Upload(IFormFile file)
        {
            if (file is null || file.Length == 0)
                return Results.BadRequest("File is invalid");
            if (!file.ContentType.StartsWith("audio/"))
                return Results.BadRequest("Only audio is accepted");
            await using var stream = file.OpenReadStream();
            var uploadParams = new VideoUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Folder = "audio_uploads",
                PublicId = $"{Path.GetFileNameWithoutExtension(file.FileName)}_{Guid.NewGuid():N}"
            };
            var uploadResult = await _cloudinary.UploadAsync(uploadParams);
            if (uploadResult.Error != null)
                return Results.Problem(uploadResult.Error.Message);
            if (uploadResult.SecureUrl is null)
                throw new Exception("Cannot get audio url");
            var res = new SpeakingAudioMeta
            {
                PublicId = uploadResult.PublicId,
                AudioUrl = uploadResult.SecureUrl.ToString(),
                Format = uploadResult.Format,
                DurationSec = uploadResult.Duration,
                Bytes = uploadResult.Bytes
            };
            return Results.Ok(new
            {
                publicId = uploadResult.PublicId,
                audioUrl = uploadResult.SecureUrl.ToString(),
                format = uploadResult.Format,
                duration = uploadResult.Duration,
                bytes = uploadResult.Bytes,
                serializedResponse = JsonSerializer.Serialize<SpeakingAudioMeta>(res)
            });
        }

    }
}