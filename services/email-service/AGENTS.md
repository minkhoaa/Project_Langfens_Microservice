# Email service
Stateless MailKit SMTP delivery driven by MassTransit; no database or migrations.

- `Features/Service/EmailSender.cs` implements `IEmailSender`; SMTP configuration is in `Contracts/SmtpOptions.cs`.
- Consumers/handlers under `Features/` receive `TestPing` and `UserRegisteredSendOtp`.
- Register consumer and explicit receive endpoint in `Program.cs`; queue names are `email-testping` and `user-registered-send-otp`.
- Auth's OTP event contract must remain compatible; message receipt is not a request to persist identity state here.
- SMTP reads `SMTP__*`; never send real mail during unit verification. Mock delivery or use an explicitly selected test SMTP sink.
- REST OTP/test-push endpoints can cause real SMTP/broker side effects; do not use them as passive health probes.
- Build from root: `dotnet build services/email-service/email-service.csproj`.
- No dedicated test project exists; isolate `IEmailSender` and use an in-memory MassTransit harness for consumer tests.
