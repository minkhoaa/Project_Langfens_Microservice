namespace email_service.Contracts;

public class RabbitMqConfig {
    public string Host { get; init; } = "localhost";
    public ushort Port { get; init; } = 5672;
    public string VirtualHost { get; init; } = "/";
    public string Username { get; init; } = "guest";
    public string Password { get; init; } = "guest";
    public bool UseSsl { get; init; } = false; 
}