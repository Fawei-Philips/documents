using System.Text.Json.Serialization;

namespace Messaging.Http.Response
{
    public class ApiResult<TPayload> where TPayload : class
    {
        [JsonPropertyName("code")]
        public int Code { get; set; }

        [JsonPropertyName("data")]
        public TPayload? Data { get; set; }

        [JsonPropertyName("msg")]
        public string? Message { get; set; }

        public bool IsSuccess => Code == 0;
    }
}
