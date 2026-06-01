using System.Text.Json;

namespace Utils.Json
{
    public static class JsonSerializerUtil
    {
        public static string SerializeCamelCase<TValue>(TValue value)
        {
            var serializeOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = true,
            };
            return JsonSerializer.Serialize(value, serializeOptions);
        }
    }
}
