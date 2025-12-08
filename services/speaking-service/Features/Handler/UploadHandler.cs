using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using speaking_service.Features.Services.User;

namespace speaking_service.Features.Handler
{
    public static class UploadHandler
    {
        public static Task<IResult> UploadAudioHandler(
            IFormFile file, ICloudinaryService service
        ) => service.Upload(file);
    }
}