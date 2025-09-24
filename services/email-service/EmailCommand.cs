namespace EmailService;

public sealed class EmailCommand
{
    public EmailCommand(string to, string subject, string template, IDictionary<string, object?>? variables = null)
    {
        if (string.IsNullOrWhiteSpace(to))
        {
            throw new ArgumentException("Recipient address is required.", nameof(to));
        }

        if (string.IsNullOrWhiteSpace(subject))
        {
            throw new ArgumentException("Subject is required.", nameof(subject));
        }

        if (string.IsNullOrWhiteSpace(template))
        {
            throw new ArgumentException("Template name is required.", nameof(template));
        }

        To = to;
        Subject = subject;
        Template = template;
        Variables = variables is null
            ? new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase)
            : new Dictionary<string, object?>(variables, StringComparer.OrdinalIgnoreCase);
    }

    public string To { get; }
    public string Subject { get; }
    public string Template { get; }
    public IDictionary<string, object?> Variables { get; }
}
