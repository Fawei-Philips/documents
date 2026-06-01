using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Net;

namespace NetUtils.Aspnet.Filters
{
    public class GlobalExceptionFilter : IAsyncExceptionFilter
    {
        private readonly ILogger<GlobalExceptionFilter> _logger;
        private readonly IWebHostEnvironment _hostEnvironment;
        public GlobalExceptionFilter(ILogger<GlobalExceptionFilter> logger, IWebHostEnvironment hostEnvironment)
        {
            _logger = logger;
            _hostEnvironment = hostEnvironment;
        }

        public async Task OnExceptionAsync(ExceptionContext context)
        {
            var exception = context.Exception;

            var innerMostException = GetInnerMostException(exception);
            _logger.LogError(innerMostException, $"An unhandled exception occurred.{innerMostException.Message}");

            var errorResponse = new ErrorResponse
            {
                StatusCode = (int)HttpStatusCode.InternalServerError,
                Message = "Server error, please try again later on."
            };

            if (_hostEnvironment.IsDevelopment())
            {
                errorResponse.Message = innerMostException.Message;
                errorResponse.Details = innerMostException.StackTrace;
            }

            context.ExceptionHandled = true;
            await Task.CompletedTask;
        }

        private Exception GetInnerMostException(Exception exception)
        {
            while (exception.InnerException != null)
            {
                exception = exception.InnerException;
            }
            return exception;
        }
    }

    public class ErrorResponse
    {
        public int StatusCode { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? Details { get; set; }
    }
}
