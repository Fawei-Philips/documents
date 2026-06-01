using Logging;
using System.Text;
using Utils;
using Utils.Enumerable;
using Utils.Generic;

namespace Messaging.Http.Exceptions
{
    public class HttpException : Exception
    {
        public HttpStatus ErrCode { get; private set; }

        public Dictionary<string, string> Messages { get; private set; } = new Dictionary<string, string>();

        public HttpException(string message, HttpStatus errCode = HttpStatus.Exception)
            : base(message)
        {
            ErrCode = errCode;
            Messages.Add("HttpException", message);
        }

        public HttpException(HttpRequestException ex) : base(ex.Message, ex)
        {
            ErrCode = ex.StatusCode.ToHttpStatus();
            Messages.Add("HttpException", ex.Message);
        }

        public HttpException(Exception ex, string message, HttpStatus errCode = HttpStatus.Exception)
            : base(message, ex)
        {
            ErrCode = errCode;
            if (ex.InnerException != null)
            {
                GetInnerException(ex);
            }
        }

        private void GetInnerException(Exception ex)
        {
            int count = 0;

            try
            {
                string? exCode = null;
                if (ex.InnerException == null)
                {
                    return;
                }

                if (ex.InnerException is HttpRequestException)
                {
                    var httpEx = ex.InnerException as HttpRequestException;
                    var status = httpEx?.StatusCode?.ToHttpStatus();
                    if (status != null)
                    {
                        ErrCode = status.Value;
                    }
                    exCode = httpEx?.StatusCode.NotNullString();
                }

                var exType = ex.InnerException.GetType().Name;
                Messages.Add($"InnerException:[{exType}][{count++}]",
                    $"message:{ex.InnerException.Message}, code={exCode}");

                GetInnerException(ex.InnerException);
            }
            catch (Exception error)
            {
                Log4Logger.Logger.Error("Error while processing inner exception", error);
            }
        }

        public string GetDetailedMessages()
        {
            var sb = new StringBuilder();
            sb.AppendLine($"Print HttpException start----------");
            sb.AppendLine($"Error message summary: {Message}");
            if (Messages.HasItem())
            {
                foreach (var message in Messages)
                {
                    sb.AppendLine($"{message.Key}: {message.Value}");
                }
            }
            sb.AppendLine($"Print HttpException end----------");

            return sb.ToString();
        }
    }
}
