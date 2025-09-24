using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Logging;
using MimeKit;

namespace EmailService;

public sealed class SmtpEmailSender
{
    private readonly EmailSettings _settings;
    private readonly ILogger<SmtpEmailSender> _logger;

    public SmtpEmailSender(EmailSettings settings, ILogger<SmtpEmailSender> logger)
    {
        _settings = settings;
        _logger = logger;
    }

    public async Task SendAsync(string to, string subject, string htmlBody, CancellationToken cancellationToken = default)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(_settings.From));
        message.To.Add(MailboxAddress.Parse(to));
        message.Subject = subject;
        message.Body = new TextPart("html") { Text = htmlBody };

        using var client = new SmtpClient();

        try
        {
            await ConnectAsync(client, cancellationToken).ConfigureAwait(false);
            await client.SendAsync(message, cancellationToken).ConfigureAwait(false);
            await client.DisconnectAsync(true, cancellationToken).ConfigureAwait(false);
        }
        catch
        {
            if (client.IsConnected)
            {
                await client.DisconnectAsync(true, cancellationToken).ConfigureAwait(false);
            }
            throw;
        }
    }

    private async Task ConnectAsync(SmtpClient client, CancellationToken cancellationToken)
    {
        if (_settings.Driver == EmailDriver.Gmail)
        {
            await client.ConnectAsync("smtp.gmail.com", 587, SecureSocketOptions.StartTls, cancellationToken).ConfigureAwait(false);
            await client.AuthenticateAsync(_settings.GmailUser, _settings.GmailAppPassword, cancellationToken).ConfigureAwait(false);
            return;
        }

        var secureOption = _settings.SmtpUseSsl
            ? SecureSocketOptions.SslOnConnect
            : _settings.SmtpUseStartTls
                ? SecureSocketOptions.StartTls
                : SecureSocketOptions.None;

        await client.ConnectAsync(_settings.SmtpHost, _settings.SmtpPort, secureOption, cancellationToken).ConfigureAwait(false);

        if (!string.IsNullOrWhiteSpace(_settings.SmtpUser) && !string.IsNullOrWhiteSpace(_settings.SmtpPassword))
        {
            await client.AuthenticateAsync(_settings.SmtpUser, _settings.SmtpPassword, cancellationToken).ConfigureAwait(false);
        }
    }
}
