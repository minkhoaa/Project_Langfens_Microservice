using System.Text.Json;

namespace EmailService;

public static class JsonValueConverter
{
    public static Dictionary<string, object?> FromObjectDictionary(Dictionary<string, JsonElement> source)
    {
        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        foreach (var kvp in source)
        {
            result[kvp.Key] = ToObject(kvp.Value);
        }
        return result;
    }

    public static object? ToObject(JsonElement element)
    {
        return element.ValueKind switch
        {
            JsonValueKind.Null or JsonValueKind.Undefined => null,
            JsonValueKind.String => element.GetString(),
            JsonValueKind.Number => element.TryGetInt64(out var l) ? l : element.GetDouble(),
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Object => ToDictionary(element),
            JsonValueKind.Array => element.EnumerateArray().Select(ToObject).ToList(),
            _ => element.GetRawText()
        };
    }

    public static Dictionary<string, object?> ToDictionary(JsonElement element)
    {
        if (element.ValueKind != JsonValueKind.Object)
        {
            throw new InvalidOperationException("JsonElement is not an object.");
        }

        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        foreach (var property in element.EnumerateObject())
        {
            result[property.Name] = ToObject(property.Value);
        }
        return result;
    }
}
