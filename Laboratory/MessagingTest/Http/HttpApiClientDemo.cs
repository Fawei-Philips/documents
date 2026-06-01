using Messaging.Http.Ioc;

namespace MessagingTest.Http;

public class HttpApiClientDemo
{
    
    private readonly Lazy<HttpClientContainer> _instance = new(() => new HttpClientContainer());
    private HttpClientContainer HttpClientContainer => _instance.Value;
    
    public HttpApiClientDemo()
    {
        InitClient();
    }

    private void InitClient()
    {
        HttpClientContainer.Services.AddHttpClient("demoHttpClient", clientOptions =>
        {
            clientOptions.BaseAddress = new Uri("https://localhost:5001");
            
        });
    }
}