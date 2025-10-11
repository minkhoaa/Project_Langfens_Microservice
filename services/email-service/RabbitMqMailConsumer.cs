using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace EmailService;

public sealed class RabbitMqMailConsumer : BackgroundService
{
    private const string ExchangeName = "mail.commands";
    private const string RoutingKey = "email.send";
    private const string QueueName = "email.send.queue";

    private readonly EmailSettings _settings;
    private readonly TemplatedEmailService _mailService;
    private readonly ILogger<RabbitMqMailConsumer> _logger;

    private IConnection? _connection;
    private IModel? _channel;
    private string? _consumerTag;
    private CancellationToken _stoppingToken;

    public RabbitMqMailConsumer(
        EmailSettings settings,
        TemplatedEmailService mailService,
        ILogger<RabbitMqMailConsumer> logger)
    {
        _settings = settings;
        _mailService = mailService;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _stoppingToken = stoppingToken;

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                InitializeConsumer();
                try
                {
                    await Task.Delay(Timeout.Infinite, stoppingToken).ConfigureAwait(false);
                }
                catch (TaskCanceledException)
                {
                    // expected on shutdown
                }
                return;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "RabbitMQ consumer failed to start. Retrying in 5 seconds...");
                await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken).ConfigureAwait(false);
            }
        }
    }
    public override void Dispose()
    {
        base.Dispose();
        try
        {
            if (_channel is { IsClosed: false })
            {
                if (!string.IsNullOrEmpty(_consumerTag))
                {
                    _channel.BasicCancelNoWait(_consumerTag);
                }
                _channel.Close();
            }
        }
        catch
        {
            // ignore closing errors during shutdown
        }
        finally
        {
            _channel?.Dispose();
            _connection?.Dispose();
        }
    }

    private void InitializeConsumer()
    {
        if (_connection is { IsOpen: true } && _channel is { IsClosed: false })
        {
            return;
        }

        var factory = new ConnectionFactory
        {
            Uri = new Uri(_settings.RabbitMqUri),
            DispatchConsumersAsync = true
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();
        _channel = 
        _channel.ExchangeDeclare(exchange: ExchangeName, type: ExchangeType.Topic, durable: true, autoDelete: false);
        _channel.QueueDeclare(queue: QueueName, durable: true, exclusive: false, autoDelete: false);
        _channel.QueueBind(queue: QueueName, exchange: ExchangeName, routingKey: RoutingKey);

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.Received += OnMessageReceivedAsync;

        _consumerTag = _channel.BasicConsume(queue: QueueName, autoAck: false, consumer: consumer);
        _logger.LogInformation("RabbitMQ consumer subscribed to {Queue}", QueueName);
    }

    private async Task OnMessageReceivedAsync(object sender, BasicDeliverEventArgs args)
    {
        if (_channel is null)
        {
            return;
        }

        try
        {
            var payload = Encoding.UTF8.GetString(args.Body.ToArray());
            var command = ParseCommand(payload);
            _logger.LogInformation("Processing email.send message for {Recipient}", command.To);
            await _mailService.SendEmailConfirmAsync(command, _stoppingToken).ConfigureAwait(false);
            _channel.BasicAck(args.DeliveryTag, multiple: false);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Discarding invalid message");
            _channel.BasicAck(args.DeliveryTag, multiple: false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to handle email.send message");
            _channel.BasicNack(args.DeliveryTag, multiple: false, requeue: true);
        }
    }

    private EmailCommand ParseCommand(string json)
    {
        using var document = JsonDocument.Parse(json);
        var payload = document.RootElement;
        if (TryGetPropertyCaseInsensitive(payload, "message", out var messageElement) && messageElement.ValueKind == JsonValueKind.Object)
        {
            payload = messageElement;
        }

        var to = GetRequiredString(payload, "to");
        var subject = GetRequiredString(payload, "subject");
        var template = GetRequiredString(payload, "template");

        Dictionary<string, object?>? variables = null;
        if (TryGetPropertyCaseInsensitive(payload, "variables", out var varsElement) && varsElement.ValueKind == JsonValueKind.Object)
        {
            var temp = new Dictionary<string, JsonElement>(StringComparer.OrdinalIgnoreCase);
            foreach (var property in varsElement.EnumerateObject())
            {
                temp[property.Name] = property.Value;
            }
            variables = JsonValueConverter.FromObjectDictionary(temp);
        }

        return new EmailCommand(to, subject, template, variables);
    }

    private static string GetRequiredString(JsonElement element, string propertyName)
    {
        if (TryGetPropertyCaseInsensitive(element, propertyName, out var value))
        {
            if (value.ValueKind == JsonValueKind.String)
            {
                var stringValue = value.GetString();
                if (!string.IsNullOrWhiteSpace(stringValue))
                {
                    return stringValue;
                }
            }
            else if (value.ValueKind == JsonValueKind.Number && value.TryGetInt64(out var number))
            {
                return number.ToString(System.Globalization.CultureInfo.InvariantCulture);
            }
        }

        throw new InvalidOperationException($"Message missing required field '{propertyName}'.");
    }

    private static bool TryGetPropertyCaseInsensitive(JsonElement element, string propertyName, out JsonElement value)
    {
        if (element.ValueKind != JsonValueKind.Object)
        {
            value = default;
            return false;
        }

        foreach (var property in element.EnumerateObject())
        {
            if (string.Equals(property.Name, propertyName, StringComparison.OrdinalIgnoreCase))
            {
                value = property.Value;
                return true;
            }
        }

        value = default;
        return false;
    }
}
