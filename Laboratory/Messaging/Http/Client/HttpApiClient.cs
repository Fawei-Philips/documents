using Logging;
using Messaging.Http.Content;
using Messaging.Http.Exceptions;
using System.Net.Http.Json;
using System.Text.Json;
using Utils.Enumerable;
using Utils.Json;

namespace Messaging.Http.Client
{
    public class HttpApiClient : IHttpApiClient
    {
        private readonly HttpClient _httpClient;


        public HttpApiClient(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        #region Header

        private void AddHeaders(HttpRequestMessage request, IHttpApiContent content)
        {
            if (content == null)
                return;
            if (!content.Headers.HasItem())
                return;

            try
            {
                foreach (var (key, value) in content.Headers)
                {
                    if (!request.Headers.Contains(key))
                    {
                        request.Headers.TryAddWithoutValidation(key, value);
                    }
                }
            }
            catch (Exception ex)
            {
                Log4Logger.Logger.Error("HttpClient AddHeaders Error", ex);
                throw new HttpException(ex, ex.Message, HttpStatus.AddRequestHeader);
            }
        }

        private void AddHeaders(HttpClient client, IHttpApiContent content)
        {
            if (content == null)
                return;
            if (!content.Headers.HasItem())
                return;

            try
            {
                foreach (var (key, value) in content.Headers)
                {
                    if (!client.DefaultRequestHeaders.Contains(key))
                    {
                        client.DefaultRequestHeaders.TryAddWithoutValidation(key, value);
                    }
                }
            }
            catch (Exception ex)
            {
                Log4Logger.Logger.Error("HttpClient AddHeaders Error", ex);
                throw new HttpException(ex, ex.Message, HttpStatus.AddRequestHeader);
            }
        }

        #endregion Header

        #region Content

        private HttpContent BuildHttpContent(IHttpApiContent content)
        {
            if (content == null)
            {
                throw new HttpException("Http request Content is null.", HttpStatus.NoContent);
            }

            var contentType = content.ContentType?.MediaType;
            if (contentType == null)
            {
                throw new HttpException("Http request ContentType is null.", HttpStatus.RequestInvalidContentType);
            }

            try
            {
                if (contentType.Equals("application/json", StringComparison.OrdinalIgnoreCase))
                {
                    return content.GetJsonContent();
                }

                if (contentType.Equals("application/x-www-form-urlencoded", StringComparison.OrdinalIgnoreCase))
                {
                    return content.GetStringContent();
                }

                if (contentType.Equals("text/plain", StringComparison.OrdinalIgnoreCase))
                {
                    return content.GetStringContent();
                }

                return JsonContent.Create(content.Content, content.ContentType, JsonEncoder.JsonOption);
            }
            catch (Exception ex)
            {
                Log4Logger.Logger.Error("HttpClient BuildHttpContent Error", ex);
                throw new HttpException(ex, ex.Message, HttpStatus.BuildRequestContent);
            }
        }

        #endregion Content

        #region Methods

        public async Task<string> GetStringAsync(IHttpApiContent content,
            CancellationToken? cancellationToken = null)
        {
            var cts = cancellationToken ?? CancellationToken.None;
            using var request = new HttpRequestMessage(HttpMethod.Get, content.RequestUrl);

            AddHeaders(request, content);

            return await SendRequestAsync<string>(request, cts);
        }

        public async Task<TResponse> GetAsync<TResponse>(IHttpApiContent content,
            CancellationToken? cancellationToken = null) where TResponse : class
        {
            var cts = cancellationToken ?? CancellationToken.None;
            using var request = new HttpRequestMessage(HttpMethod.Get, content.RequestUrl);

            AddHeaders(request, content);

            return await SendRequestAsync<TResponse>(request, cts);
        }

        public async Task<TResponse> PostAsync<TResponse>(IHttpApiContent content, 
            CancellationToken? cancellationToken = null) where TResponse : class
        {
            if (content == null)
            {
                throw new HttpException("Http request Content is null.", HttpStatus.NoContent);
            }

            var cts = cancellationToken ?? CancellationToken.None;

            using var request = new HttpRequestMessage(HttpMethod.Post, content.RequestUrl);

            AddHeaders(request, content);
            request.Content = BuildHttpContent(content);
            return await SendRequestAsync<TResponse>(request, cts);
        }

        public async Task<string?> PostAsync(IHttpApiContent content,
                CancellationToken? cancellationToken = null)
        {
            if (content == null)
            {
                throw new HttpException("Http request Content is null.", HttpStatus.NoContent);
            }

            var cts = cancellationToken ?? CancellationToken.None;

            try
            {
                AddHeaders(_httpClient, content);
                var response = await _httpClient.PostAsJsonAsync(content.RequestUrl, content.Content, JsonEncoder.JsonOption, cts);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync(cts);
            }
            catch (HttpRequestException ex)
            {
                throw new HttpException(ex);
            }
            catch (Exception ex)
            {
                throw new HttpException(ex, ex.Message, HttpStatus.PostFailed);
            }
        }

        private async Task<TResponse> SendRequestAsync<TResponse>(HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            try
            {
                using var response = await _httpClient.SendAsync(
                    request,
                    HttpCompletionOption.ResponseHeadersRead,
                    cancellationToken);

                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);
                Log4Logger.Logger.Debug(responseContent);

                if (!response.IsSuccessStatusCode)
                {
                    throw new HttpException(
                        $"Failed to fetch http data: {response.ReasonPhrase}:{responseContent}",
                        response.StatusCode.ToHttpStatus());
                }

                if (string.IsNullOrWhiteSpace(responseContent))
                {
                    return default!;
                }

                return JsonSerializer.Deserialize<TResponse>(responseContent, JsonEncoder.JsonOption)
                    ?? throw new HttpException("Failed to Deserialize http response.", HttpStatus.ResponseDeserialize);
            }
            catch (HttpRequestException ex)
            {
                throw new HttpException(ex);
            }
            catch (TaskCanceledException ex)
            {
                if (cancellationToken.IsCancellationRequested)
                {
                    throw new HttpException(ex, "Http Request Canceled.", HttpStatus.RequestCancelled);
                }
                throw new HttpException(ex, "Http Request Timeout.", HttpStatus.RequestTimeout);
            }
            catch (JsonException ex)
            {
                throw new HttpException(ex, "Failed to Deserialize http response.", HttpStatus.ResponseDeserialize);
            }
        }

        #endregion Methods


        #region Log

        public void Log(string message)
        {
            var threadId = Environment.CurrentManagedThreadId;
            Log4Logger.Logger.Info($"[Thread: {threadId}]{message}");
        }

        #endregion Log
    }
}
