using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RabbitMQ.Client;

namespace writing_service.Features.Helper
{

    public record RabbitMqConfig
    {
        public string Host { get; init; } = "localhost";
        public ushort Port { get; init; } = 5672;
        public string VirtualHost { get; init; } = "/";
        public string Username { get; init; } = "guest";
        public string Password { get; init; } = "guest";
        public bool UseSsl { get; init; } = false;
    }
}