using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Unicode;

namespace Utils.Json
{
    public static class JsonEncoder
    {
        public static readonly JsonSerializerOptions JsonOption = new JsonSerializerOptions
        {
            Encoder = JavaScriptEncoder.Create(UnicodeRanges.All)
        };

    }
}
