using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Logging;

namespace EmailService;

public sealed class TemplatedEmailService
{
    private readonly EmailTemplateRenderer _renderer;
    private readonly SmtpEmailSender _sender;
    private readonly EmailSettings _settings;
    private readonly ILogger<TemplatedEmailService> _logger;

    public TemplatedEmailService(
        EmailTemplateRenderer renderer,
        SmtpEmailSender sender,
        EmailSettings settings,
        ILogger<TemplatedEmailService> logger)
    {
        _renderer = renderer;
        _sender = sender;
        _settings = settings;
        _logger = logger;
    }

    public async Task SendAsync(EmailCommand command, CancellationToken cancellationToken = default)
    {
        var html = await _renderer.RenderAsync(command.Template, command.Variables, cancellationToken).ConfigureAwait(false);
        _logger.LogInformation("Sending email to {Recipient} with subject {Subject}", command.To, command.Subject);
        await _sender.SendAsync(command.To, command.Subject, html, cancellationToken).ConfigureAwait(false);
    }

    public async Task SendEmailConfirmAsync(EmailCommand command, CancellationToken cancellationToken = default)
    {
        var enrichedVariables = new Dictionary<string, object?>(command.Variables, StringComparer.OrdinalIgnoreCase);

        if (!enrichedVariables.ContainsKey("verifyUrl"))
        {
            var uid = ExtractAsString(enrichedVariables, "uid");
            var token = ExtractAsString(enrichedVariables, "token");
            var verifyUrl = BuildVerifyUrl(uid, token);
            if (!string.IsNullOrWhiteSpace(verifyUrl))
            {
                enrichedVariables["verifyUrl"] = verifyUrl;
            }
        }

        var enrichedCommand = new EmailCommand(command.To, command.Subject, command.Template, enrichedVariables);
        await SendAsync(enrichedCommand, cancellationToken).ConfigureAwait(false);
    }

    private static string? ExtractAsString(IDictionary<string, object?> source, string key)
    {
        if (!source.TryGetValue(key, out var value) || value is null)
        {
            return null;
        }

        return value switch
        {
            string s => s,
            IFormattable f => f.ToString(null, System.Globalization.CultureInfo.InvariantCulture),
            _ => value.ToString()
        };
    }

    private string? BuildVerifyUrl(string? uid, string? token)
    {
        if (string.IsNullOrWhiteSpace(uid) || string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        if (!Uri.TryCreate(_settings.VerifyCallbackBase, UriKind.Absolute, out var baseUri))
        {
            _logger.LogWarning("Verify callback base URL is invalid: {Url}", _settings.VerifyCallbackBase);
            return null;
        }

        var query = QueryHelpers.ParseQuery(baseUri.Query);
        var queryDict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var pair in query)
        {
            queryDict[pair.Key] = pair.Value.LastOrDefault() ?? string.Empty;
        }

        queryDict["id"] = uid;
        queryDict["token"] = token;

        var baseWithoutQuery = baseUri.GetLeftPart(UriPartial.Path);
        var urlWithQuery = QueryHelpers.AddQueryString(baseWithoutQuery, queryDict);
        if (!string.IsNullOrEmpty(baseUri.Fragment))
        {
            urlWithQuery += baseUri.Fragment;
        }

        return urlWithQuery;
    }
}
