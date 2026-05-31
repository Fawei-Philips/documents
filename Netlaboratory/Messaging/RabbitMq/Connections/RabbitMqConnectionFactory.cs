using Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using Utils.Ioc;
using Utils.Tasking;

namespace Messaging.RabbitMq.Connections
{
    [Register(ServiceType = typeof(IRabbitMqConnectionFactory), Lifetime = Lifetime.Singleton)]
    public class RabbitMqConnectionFactory : IRabbitMqConnectionFactory
    {
        public ConnectionFactory? ConnectionFactory { get; private set; }
        private IConnection? _connection;
        private readonly Task<IConnection> _connectionBuildingTask;

        public RabbitMqSettings RabbitMqSettings { get; }

        public RabbitMqConnectionFactory(IOptions<RabbitMqSettings> rabbitMqSettingsOption)
        {
            RabbitMqSettings = rabbitMqSettingsOption.Value;
            _connectionBuildingTask = BuildConnectionAsync();
            _connectionBuildingTask.SafeFireAndForget(OnInitCompleted, OnInitError);
        }

        private void OnInitError(Exception exception)
        {
            Log4Logger.Logger.Error($"RabbitMQ Connection initialized failed.", exception);
        }

        private void OnInitCompleted(IConnection connection)
        {
            _connection = connection;
            Log4Logger.Logger.Info($"RabbitMQ Connection initialized successfully.");
        }

        public virtual async Task<IConnection> BuildConnectionAsync()
        {
            ConnectionFactory = new ConnectionFactory
            {
                HostName = RabbitMqSettings.HostName,
                Port = RabbitMqSettings.Port,
                UserName = RabbitMqSettings.UserName,
                Password = RabbitMqSettings.Password,
                VirtualHost = RabbitMqSettings.VirtualHost ?? "/"
            };

            var connection = await ConnectionFactory.CreateConnectionAsync();
            return connection;
        }

        public async ValueTask<IConnection> GetConnectionAsync()
        {
            if (_connection != null)
            {
                return _connection;
            }

            return await _connectionBuildingTask;
        }
    }
}
