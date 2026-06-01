using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace Messaging.Http.Content
{
    public interface IHttpApiContent
    {
        public Dictionary<string, string> Headers { get; }
        public Dictionary<string, object> Content { get; }
        public MediaTypeHeaderValue ContentType { get; set; }
        public string RequestUrl { get; set; }
        StringContent GetJsonContent();
        StringContent GetStringContent();
    }
}
