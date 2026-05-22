# email-service

Email dispatch service using MailKit/MassTransit. No database — purely message-driven.

## Service Overview
- **Port**: HTTP health + AMQP consumer port (no dedicated HTTP port beyond health)
- **Stack**: ASP.NET Core 10, MassTransit/RabbitMQ, MailKit (SMTP)
- **Database**: None
- **Key pattern**: Consumes RabbitMQ messages, dispatches SMTP emails via MailKit

## Key Files
```
Program.cs                           Entry point
Contracts/
  SmtpConfig.cs                      SMTP configuration (host, port, credentials)
Features/
  Service/EmailSender.cs             IEmailSender — MailKit SMTP implementation
  Worker/                            Background workers (if any)
  Handler/                           Message handlers
  Endpoint/                          Minimal REST endpoints (test ping, OTP send)
  TestpingConsumer.cs                MassTransit consumer for TestPing message
```

## MassTransit / RabbitMQ Consumer Pattern
This service is **primarily a consumer**:
```csharp
// Program.cs
builder.Services.AddMassTransit(cfg =>
{
    cfg.AddConsumer<TestpingConsumer>();
    cfg.AddConsumer<UserRegisteredSendOtpConsumer>();
    cfg.UsingRabbitMq((ctx, bus) =>
    {
        bus.Host(...);
        bus.ReceiveEndpoint("email-testping", e => e.ConfigureConsumer<TestpingConsumer>(ctx));
        bus.ReceiveEndpoint("user-registered-send-otp", e => e.ConfigureConsumer<UserRegisteredSendOtpConsumer>(ctx));
    });
});
```

### Adding a new email consumer
1. Create `Features/Handler/{EventName}Consumer.cs` implementing `IConsumer<TMessage>`
2. Inject `IEmailSender` to send emails in `Consume()` method
3. Register consumer + endpoint in `Program.cs`

### REST test endpoints
- `POST /send-otp` — direct OTP email dispatch (for testing)
- `POST /_test/push` — publish test `TestPing` message to RabbitMQ

## How This Service Communicates with Others
- **RabbitMQ consumer**: Receives `UserRegisteredSendOtp` messages (from auth-service or other services)
- **SMTP**: Sends emails via MailKit
- **No database**: No persistence, purely reactive to messages

## SMTP Configuration (via env)
```
SMTP__HOST, SMTP__PORT, SMTP__USERNAME, SMTP__PASSWORD, SMTP__FROM,
RABBITMQ__HOST, RABBITMQ__USERNAME, RABBITMQ__PASSWORD, RABBITMQ__VHOST, RABBITMQ__PORT
```

## Testing Patterns
- Unit test: `EmailSender` with mock `SmtpClient`
- Integration: Use MassTransit's in-memory test harness to verify message consumption
- Manual test: `POST /_test/push` to publish a test message