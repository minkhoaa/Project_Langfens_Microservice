using System.Text.Json;

namespace TestSupport;

public static class JsonDataExtensions
{
    public static JsonElement ToJsonElement(this object data)
        => JsonSerializer.SerializeToElement(data, new JsonSerializerOptions(JsonSerializerDefaults.Web));
}
