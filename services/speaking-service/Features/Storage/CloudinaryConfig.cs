using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace speaking_service.Features.Storage
{
    public class CloudinaryConfig
    {
        public string CloudName { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string ApiSecret { get; set; } = string.Empty;
        public CloudinaryConfig(IConfiguration configuration)
        {
            CloudName = Environment.GetEnvironmentVariable("CLOUDINARY_CLOUD_NAME")
                      ?? configuration["Cloudinary:CloudName"]
                      ?? throw new Exception("Cannot get CloudName");

            ApiKey = Environment.GetEnvironmentVariable("CLOUDINARY_API_KEY")
                        ?? configuration["Cloudinary:ApiKey"]
                        ?? throw new Exception("Cannot get ApiKey");

            ApiSecret = Environment.GetEnvironmentVariable("CLOUDINARY_API_SECRET")
                        ?? configuration["Cloudinary:ApiSecret"]
                        ?? throw new Exception("Cannot get ApiSecret");
        }
    }
}