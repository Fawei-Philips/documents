using Microsoft.Extensions.DependencyInjection;

namespace Messaging.Http.Ioc
{
    public class HttpClientContainer
    {
        private readonly IServiceCollection _serviceCollection;
        private readonly Lazy<IServiceProvider> _serviceProvider;
        public IServiceProvider ServiceProvider => _serviceProvider.Value;
        public IServiceCollection Services => _serviceCollection;
        
        public HttpClientContainer()
        {
            _serviceCollection = new ServiceCollection();
            _serviceProvider = new Lazy<IServiceProvider>(
                () => _serviceCollection.BuildServiceProvider(), LazyThreadSafetyMode.ExecutionAndPublication);
        }
    }
}
