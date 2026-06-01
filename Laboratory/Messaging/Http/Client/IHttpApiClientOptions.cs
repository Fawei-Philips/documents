namespace Messaging.Http.Client;

public interface IHttpApiClientOptions
{
    Uri? BaseAddress { get; set; }
    TimeSpan Timeout { get; set; }
    Dictionary<string, string> DefaultHeaders { get; set; }
    bool EnableRetry { get; set; }
    int MaxRetryCount { get; set; }
    TimeSpan RetryDelay { get; set; }
}