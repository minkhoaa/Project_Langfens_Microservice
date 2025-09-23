using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace EmailService;

public sealed class SendEmailRequest
{
    [Required]
    [EmailAddress]
    public string To { get; set; } = string.Empty;

    [Required]
    [MinLength(1)]
    public string Subject { get; set; } = string.Empty;

    [Required]
    [MinLength(1)]
    public string Template { get; set; } = string.Empty;

    public Dictionary<string, JsonElement>? Variables { get; set; }

    public bool TryValidate(out Dictionary<string, string[]> errors)
    {
        var context = new ValidationContext(this);
        var results = new List<ValidationResult>();
        var isValid = Validator.TryValidateObject(this, context, results, validateAllProperties: true);

        errors = results
            .GroupBy(r => r.MemberNames.FirstOrDefault() ?? string.Empty)
            .ToDictionary(g => g.Key, g => g.Select(r => r.ErrorMessage ?? "Invalid value").ToArray());

        return isValid;
    }

    public EmailCommand ToEmailCommand()
    {
        var variables = Variables is null
            ? new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase)
            : ToObjectDictionary(Variables);

        return new EmailCommand(To, Subject, Template, variables);
    }

    private static Dictionary<string, object?> ToObjectDictionary(Dictionary<string, JsonElement> source)
    {
        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        foreach (var kvp in source)
        {
            result[kvp.Key] = ConvertJson(kvp.Value);
        }
        return result;
    }

    private static object? ConvertJson(JsonElement element)
    {
        return element.ValueKind switch
        {
            JsonValueKind.Null or JsonValueKind.Undefined => null,
            JsonValueKind.String => element.GetString(),
            JsonValueKind.Number => element.TryGetInt64(out var l) ? l : element.GetDouble(),
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Object => element.EnumerateObject()
                .Aggregate(new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase), (acc, property) =>
                {
                    acc[property.Name] = ConvertJson(property.Value);
                    return acc;
                }),
            JsonValueKind.Array => element.EnumerateArray().Select(ConvertJson).ToList(),
            _ => element.GetRawText()
        };
    }
}
