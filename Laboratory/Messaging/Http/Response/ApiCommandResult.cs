using System.Text.Json.Serialization;

namespace Messaging.Http.Response
{
    public class ApiCommandResult<TPayload> where TPayload : class
    {
        [JsonPropertyName("code")]
        public int Code { get; set; }

        public CommandData<TPayload>? Data { get; set; }

        [JsonPropertyName("msg")]
        public string? Message { get; set; }

        public bool IsSuccess => Code == 0;
    }
}
