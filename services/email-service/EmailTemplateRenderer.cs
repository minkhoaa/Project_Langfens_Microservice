using System.Collections.Concurrent;
using HandlebarsDotNet;
using Microsoft.Extensions.Logging;
using Mjml.Net;

namespace EmailService;

public sealed class EmailTemplateRenderer
{
    private readonly EmailSettings _settings;
    private readonly ILogger<EmailTemplateRenderer> _logger;
    private readonly IMjmlRenderer _mjmlRenderer;
    private readonly ConcurrentDictionary<string, string> _templateCache = new(StringComparer.OrdinalIgnoreCase);
    private readonly ConcurrentDictionary<string, Func<object, string>> _compiledCache = new(StringComparer.OrdinalIgnoreCase);

    public EmailTemplateRenderer(EmailSettings settings, ILogger<EmailTemplateRenderer> logger)
    {
        _settings = settings;
        _logger = logger;
        _mjmlRenderer = new MjmlRenderer();
    }

    public async Task<string> RenderAsync(string templateName, IDictionary<string, object?> variables, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(templateName))
        {
            throw new ArgumentException("Template name is required.", nameof(templateName));
        }

        var templatePath = Path.Combine(_settings.TemplateRoot, $"{templateName}.mjml");
        if (!File.Exists(templatePath))
        {
            throw new FileNotFoundException($"Template '{templateName}' not found at '{templatePath}'.", templatePath);
        }

        var mjml = await LoadTemplateAsync(templateName, templatePath, cancellationToken).ConfigureAwait(false);
        var compiled = _compiledCache.GetOrAdd(templateName, _ => Handlebars.Compile(mjml));
        var mjmlFilled = compiled(variables);

        var result = _mjmlRenderer.Render(mjmlFilled);
        if (!result.Success)
        {
            var errors = string.Join("; ", result.Errors.Select(e => e.Message));
            _logger.LogError("MJML render failed for template {Template}: {Errors}", templateName, errors);
            throw new InvalidOperationException($"MJML render error: {errors}");
        }

        return result.Html;
    }

    private async Task<string> LoadTemplateAsync(string templateName, string templatePath, CancellationToken cancellationToken)
    {
        if (_templateCache.TryGetValue(templateName, out var cached))
        {
            return cached;
        }

        await using var stream = File.OpenRead(templatePath);
        using var reader = new StreamReader(stream);
        var content = await reader.ReadToEndAsync(cancellationToken).ConfigureAwait(false);
        _templateCache[templateName] = content;
        return content;
    }
}
