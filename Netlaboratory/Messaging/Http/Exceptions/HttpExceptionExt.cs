using System.Net;
using Utils.Generic;

namespace Messaging.Http.Exceptions
{
    public static class HttpExceptionExt
    {
        public static HttpStatus ToHttpStatus(this HttpStatusCode code)
        {
            var status = code.NotNullString();
            if (string.IsNullOrEmpty(status))
            {
                return HttpStatus.Exception;
            }
            if (Enum.TryParse<HttpStatus>(status, out var wsErrCode))
            {
                return wsErrCode;
            }
            return HttpStatus.Exception;
        }

        public static HttpStatus ToHttpStatus(this HttpStatusCode? code)
        {
            var status = code.NotNullString();
            if (string.IsNullOrEmpty(status))
            {
                return HttpStatus.Exception;
            }
            if (Enum.TryParse<HttpStatus>(status, out var wsErrCode))
            {
                return wsErrCode;
            }
            return HttpStatus.Exception;
        }
    }
}
