using Logging;
using Messaging.Http.Client;
using Messaging.Http.Exceptions;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Polly;
using Polly.Retry;

namespace Messaging.Http.Ioc;

public static class ClientRegistrationExt
{
    #region IServiceCollection
    
    extension(IServiceCollection services)
    {
        public IHttpClientBuilder AddHttpClient(
            string clientIdentifier,
            Action<IHttpApiClientOptions> configureOptions)
        {
            if (services == null)
            {
                throw new HttpException($"HttpClient Register error. Ioc Service :[{nameof(services)}] is null", HttpStatus.ClientRegister);
            }
            if (string.IsNullOrEmpty(clientIdentifier))
            {
                throw new HttpException($"HttpClient Register error. clientIdentifier is empty.", HttpStatus.ClientRegister);
            }
            if (configureOptions == null)
            {
                throw new HttpException($"HttpClient Register error. Client configureOptions is empty.", HttpStatus.ClientRegister);
            }

            services.Configure(clientIdentifier, configureOptions);

            var clientBuilder = services.AddHttpClient(clientIdentifier, (serviceProvider, httpClient) =>
            {
                BuildHttpClient(clientIdentifier, serviceProvider, httpClient);
            });
        
            return clientBuilder;
        }
        
        public IHttpClientBuilder AddHttpClientWithRetryPolicy(
            string clientIdentifier,
            Action<IHttpApiClientOptions> configureOptions)
        {
            var clientBuilder = services.AddHttpClient(clientIdentifier, configureOptions)
                .AddPolicyHandler((serviceProvider, request) =>
                {
                    var options = serviceProvider.GetClientOptions(clientIdentifier);
                    if (!options.EnableRetry || options.MaxRetryCount <= 0)
                    {
                        return Policy.NoOpAsync<HttpResponseMessage>();
                    }

                    return CreateRetryPolicy(options.MaxRetryCount, options.RetryDelay);
                });

            return clientBuilder;
        }
        
        public void AddCustomHttpClient(string clientIdentifier, 
            Func<IServiceProvider, HttpClient, IHttpApiClientOptions, IHttpApiClient> customClient)
        {
            services.AddKeyedScoped<IHttpApiClient>(clientIdentifier, (serviceProvider, client) =>
            {
                var httpClient = serviceProvider.GetRequiredService<IHttpClientFactory>().CreateClient(clientIdentifier);
                var clientOptions = serviceProvider.GetClientOptions(clientIdentifier);
                return customClient.Invoke(serviceProvider, httpClient, clientOptions);
            });
        }
    }
    
    private static void BuildHttpClient(string clientIdentifier, IServiceProvider serviceProvider, HttpClient httpClient)
    {
        var options = serviceProvider.GetClientOptions(clientIdentifier);

        if (options.BaseAddress != null)
        {
            httpClient.BaseAddress = options.BaseAddress;
        }

        httpClient.Timeout = options.Timeout;

        foreach (var (key, value) in options.DefaultHeaders)
        {
            if (!httpClient.DefaultRequestHeaders.TryAddWithoutValidation(key, value))
            {
                httpClient.DefaultRequestHeaders.Add(key, value);
            }
        }
    }
    
    private static AsyncRetryPolicy<HttpResponseMessage> CreateRetryPolicy(int maxRetryCount, TimeSpan retryDelay)
    {
        return Policy
            .Handle<HttpRequestException>()
            .OrResult<HttpResponseMessage>(response => !response.IsSuccessStatusCode &&
                                                       (int)response.StatusCode >= 500)
            .WaitAndRetryAsync(
                retryCount: maxRetryCount,
                sleepDurationProvider: retryAttempt => retryDelay * Math.Pow(2, retryAttempt - 1),
                onRetryAsync: async (outcome, timespan, retryAttempt, context) =>
                {
                    var message = outcome.Exception != null
                        ? $"Request failed, will retry in {timespan.TotalSeconds} seconds (attempt {retryAttempt}): {outcome.Exception.Message}"
                        : $"Request returned {outcome.Result.StatusCode}, will retry in {timespan.TotalSeconds} seconds (attempt {retryAttempt})";

                    Log4Logger.Logger.Warn(message);
                    await Task.CompletedTask;
                }
            );
    }
    
    #endregion IServiceCollection
    
    #region IHttpClientBuilder

    extension(IHttpClientBuilder clientBuilder)
    {
        public void AddHttpClientInterceptor<THandler>() where THandler : DelegatingHandler
        {
            if (clientBuilder == null)
            {
                throw new InvalidOperationException("IHttpClientBuilder is not created, please add an HttpClient first.");
            }

            clientBuilder.AddHttpMessageHandler<THandler>();
        }
    }
    
    #endregion IHttpClientBuilder
    
    #region IServiceProvider

    extension(IServiceProvider serviceProvider)
    {
        public TClient GetHttpClient<TClient>(string clientIdentifier) where TClient : class, IHttpApiClient
        {
            if (serviceProvider == null)
            {
                throw new InvalidOperationException(
                    "Service provider is not built. Please call BuildServiceProvider() before requesting HttpClient.");
            }

            return serviceProvider.GetRequiredKeyedService<TClient>(clientIdentifier);
        }
        
        public IHttpApiClientOptions GetClientOptions(string clientIdentifier)
        {
            return serviceProvider
                .GetRequiredService<IOptionsSnapshot<IHttpApiClientOptions>>()
                .Get(clientIdentifier);
        }
    }

    #endregion IServiceProvider
}