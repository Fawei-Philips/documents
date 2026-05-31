using RabbitMQ.Client;

namespace Messaging.RabbitMq.Connections
{
    public interface IRabbitMqConnectionFactory
    {
        Task<IConnection> BuildConnectionAsync();
        ConnectionFactory? ConnectionFactory { get; }
        RabbitMqSettings RabbitMqSettings { get; }
        ValueTask<IConnection> GetConnectionAsync();
    }
}
