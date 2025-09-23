using System.Globalization;

namespace EmailService;

public enum EmailDriver
{
    Gmail,
    Smtp
}

public sealed class EmailSettings
{
    public EmailDriver Driver { get; }
    public string From { get; }
    public string? GmailUser { get; }
    public string? GmailAppPassword { get; }
    public string SmtpHost { get; }
    public int SmtpPort { get; }
    public bool SmtpUseSsl { get; }
    public bool SmtpUseStartTls { get; }
    public string? SmtpUser { get; }
    public string? SmtpPassword { get; }
    public string VerifyCallbackBase { get; }
    public string TemplateRoot { get; }
    public string RabbitMqUri { get; }

    private EmailSettings(
        EmailDriver driver,
        string from,
        string? gmailUser,
        string? gmailAppPassword,
        string smtpHost,
        int smtpPort,
        bool smtpUseSsl,
        bool smtpUseStartTls,
        string? smtpUser,
        string? smtpPassword,
        string verifyCallbackBase,
        string templateRoot,
        string rabbitMqUri)
    {
        Driver = driver;
        From = from;
        GmailUser = gmailUser;
        GmailAppPassword = gmailAppPassword;
        SmtpHost = smtpHost;
        SmtpPort = smtpPort;
        SmtpUseSsl = smtpUseSsl;
        SmtpUseStartTls = smtpUseStartTls;
        SmtpUser = smtpUser;
        SmtpPassword = smtpPassword;
        VerifyCallbackBase = verifyCallbackBase;
        TemplateRoot = templateRoot;
        RabbitMqUri = rabbitMqUri;
    }

    public static EmailSettings FromConfiguration(IConfiguration configuration)
    {
        if (configuration is null)
        {
            throw new ArgumentNullException(nameof(configuration));
        }

        var driverValue = configuration["MAIL_DRIVER"] ?? "smtp";
        var driver = driverValue.Equals("gmail", StringComparison.OrdinalIgnoreCase) ? EmailDriver.Gmail : EmailDriver.Smtp;

        var from = configuration["MAIL_FROM"] ?? "no-reply@example.com";
        if (string.IsNullOrWhiteSpace(from))
        {
            throw new InvalidOperationException("MAIL_FROM must be provided.");
        }

        var templateRoot = configuration["EMAIL_TEMPLATE_ROOT"];
        if (string.IsNullOrWhiteSpace(templateRoot))
        {
            templateRoot = Path.Combine(AppContext.BaseDirectory, "templates");
        }
        else if (!Path.IsPathRooted(templateRoot))
        {
            templateRoot = Path.GetFullPath(templateRoot, AppContext.BaseDirectory);
        }

        var verifyCallbackBase = configuration["VERIFY_CALLBACK_BASE"] ?? "http://localhost:8080/auth/verify-email";
        var rabbitMqUri = configuration["RABBIT_URI"] ?? "amqp://guest:guest@emailservice-mq:5672";

        var smtpHost = configuration["MAIL_SMTP_HOST"] ?? "localhost";
        var smtpPort = configuration.GetValue<int?>("MAIL_SMTP_PORT") ?? 1025;
        var smtpSecure = configuration.GetValue<bool?>("MAIL_SMTP_SECURE") ?? false;
        var smtpStartTls = configuration.GetValue<bool?>("MAIL_SMTP_STARTTLS") ?? false;
        var smtpUser = configuration["MAIL_SMTP_USER"];
        var smtpPass = configuration["MAIL_SMTP_PASS"];

        var gmailUser = configuration["GMAIL_USER"];
        var gmailAppPass = configuration["GMAIL_APP_PASS"];

        if (driver == EmailDriver.Gmail)
        {
            if (string.IsNullOrWhiteSpace(gmailUser) || string.IsNullOrWhiteSpace(gmailAppPass))
            {
                throw new InvalidOperationException("GMAIL_USER and GMAIL_APP_PASS must be provided when MAIL_DRIVER is 'gmail'.");
            }
        }

        return new EmailSettings(
            driver,
            from,
            gmailUser,
            gmailAppPass,
            smtpHost,
            smtpPort,
            smtpSecure,
            smtpStartTls,
            smtpUser,
            smtpPass,
            verifyCallbackBase,
            templateRoot,
            rabbitMqUri);
    }
}
