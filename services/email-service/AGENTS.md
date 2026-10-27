# Email service
Stateless MailKit SMTP delivery via MassTransit; no database or migrations.

- `Features/Service/EmailSender.cs` implements `IEmailSender`; `Contracts/SmtpOptions.cs` binds `SMTP__*`.
- Preserve explicit queues `email-testping` and `user-registered-send-otp` in `Program.cs`.
- `UserRegisteredSendOtp` must match auth's producer; identity persistence stays in auth-service.
- OTP/test-push endpoints send real mail/messages, not passive health probes; use a test sink/mock sender.
- Verify consumers with an in-memory MassTransit harness rather than a live SMTP account.
