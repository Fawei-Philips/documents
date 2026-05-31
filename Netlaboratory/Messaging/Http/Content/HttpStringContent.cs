using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Utils.Enumerable;
using Utils.Generic;
using Utils.Json;

namespace Messaging.Http.Content
{
    public class HttpStringContent : IHttpApiContent
    {
        #region Properties

        public Dictionary<string, string> Headers { get; private set; }
        public Dictionary<string, object> Content { get; private set; }
        public MediaTypeHeaderValue ContentType { get; set; } = MediaTypeHeaderValue.Parse("application/json");
        public string RequestUrl { get; set; }

        #endregion Properties

        public HttpStringContent(string url)
        {
            RequestUrl = url;
            Content = new Dictionary<string, object>();
            Headers = new Dictionary<string, string>();
        }

        #region Header

        public void AddHeader(string key, string value)
        {
            Headers.AddOrUpdate(key, value);
        }

        public void AddHeader(Dictionary<string, object> source, string key)
        {
            Headers.AddOrUpdate(key, source[key].NotNullString());
        }

        public void AddHeaders(Dictionary<string, string> pairs)
        {
            Headers.AddOrUpdate(pairs);
        }

        #endregion Header

        #region Content

        public void AddContent(string key, object value)
        {
            Content.AddOrUpdate(key, value);
        }

        public void AddContent(Dictionary<string, object> source, string key)
        {
            Content.AddOrUpdate(key, source[key]);
        }
        public void AddContents(Dictionary<string, object> pairs)
        {
            Content.AddOrUpdate(pairs);
        }

        public virtual StringContent GetJsonContent()
        {
            var jsonContent = JsonSerializer.Serialize(Content, JsonEncoder.JsonOption);
            var stringContent = new StringContent(jsonContent, Encoding.UTF8, ContentType);
            return stringContent;
        }

        public virtual StringContent GetStringContent()
        {
            var sb = new StringBuilder();
            foreach(var item in Content)
            {
                sb.Append($"{item.Key}={item.Value}&");
            }
            var stringContent = sb.ToString().TrimEnd('&');

            return new StringContent(stringContent, Encoding.UTF8, ContentType);
        }

        public virtual StringContent GetArrayContent()
        {
            var sb = new StringBuilder();
            foreach (var value in Content.Values)
            {
                sb.Append($"{value},");
            }
            var stringContent = sb.ToString().TrimEnd(',');
            stringContent = $"[{stringContent}]";

            return new StringContent(stringContent, Encoding.UTF8, ContentType);
        }

        private string ToJson(object content)
        {
            var json = JsonSerializer.Serialize(content, JsonEncoder.JsonOption);
            return json;
        }

        #endregion Content
    }
}
