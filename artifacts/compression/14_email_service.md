# 14 — email-service

> Source-of-truth: `services/email-service/*`. Verified by direct reads.

## Role in the system

Pure message-driven email dispatcher. No database, no domain state. Subscribes to:

- `email-testping` queue (`TestPingConsumer`) — dev/test ping.
- `user-registered-send-otp` queue (`UserRegisteredSendOtpConsumer`) — production OTP emails from `auth-service`.

Sends via **MailKit SMTP** using `IEmailSender`.

## Stack

- ASP.NET Core 10, MassTransit + RabbitMQ, **MailKit** SMTP.
- No EF Core, no DB, no JWT validation — service is internal-only behind the gateway with `email-cluster` (20s timeout).

## Configuration

`Contracts/SmtpConfig.cs` — bound from `SMTP__HOST/PORT/USERNAME/PASSWORD/FROM`.

`Program.cs` also adds:

```csharp
builder.Services.AddSmtpConfig(key => Environment.GetEnvironmentVariable(key));
```

(Extension lives in service-local code — see `Contracts/SmtpConfig.cs` for the binding pattern.)

## Consumers

- `Features/Worker/UserRegisteredSendOtpConsumer : IConsumer<UserRegisteredSendOtp>` → `sender.SendOtpAsync(context.Message.Email, context.Message.Otp, context.Message.TtlSeconds, ct)`.
- `TestpingConsumer : IConsumer<TestPing>` → logger.

## Endpoints (test only)

| Method | Path | Purpose |
|---|---|---|
| POST | `/send-otp?email=&otp=` | direct OTP email send (testing) |
| POST | `/_test/push?text=` | publish a `TestPing` to RabbitMQ |
| GET | `/api/mail/verify-email` | `MapEmailEndpoint()` placeholder |
| (ASP.NET Core health) | `/health`, `/alive` | Aspire default endpoints |

## Health checks

- `rabbitmq` (URI-based AMQP probe) — only check.

## Environment variables (verified)

| Key | Purpose |
|---|---|
| `SMTP__HOST` | SMTP host |
| `SMTP__PORT` | SMTP port |
| `SMTP__USERNAME` | SMTP user |
| `SMTP__PASSWORD` | SMTP password |
| `SMTP__FROM` | from address |
| `RABBITMQ__HOST/PORT/USERNAME/PASSWORD/VHOST/USESSL` | broker |

## Why no DB?

Stateless dispatch — failures replay from the broker's redelivery policy. Adding DB state would only complicate at-least-once guarantees.
