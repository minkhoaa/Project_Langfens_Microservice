# Email service
Stateless MailKit SMTP delivery via MassTransit; no database or migrations.

- `Features/Service/EmailSender.cs` implements `IEmailSender`; `Contracts/SmtpOptions.cs` binds `SMTP__*`.
- `Program.cs` registers consumers and explicit queues: `email-testping`, `user-registered-send-otp`.
- Preserve auth's `UserRegisteredSendOtp` contract; identity persistence belongs to auth-service.
- OTP/test-push endpoints cause real SMTP/broker effects, not passive health checks; use a test sink or mock sender.
- No dedicated tests; consumer verification should use an in-memory MassTransit harness.
