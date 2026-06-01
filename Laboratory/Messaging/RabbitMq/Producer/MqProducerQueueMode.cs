using Logging;
using Messaging.RabbitMq.Connections;
using Messaging.RabbitMq.Producer;
using RabbitMQ.Client;
using RabbitMQ.Client.Exceptions;
using System.Text;
using System.Text.Json;
using Utils.Tasking;

namespace service.messaging.Clients.RabbitMq.Producer
{
    public class MqProducerQueueMode<TPayload> : IRabbitMqProducer<TPayload> where TPayload : class
    {
        private readonly IRabbitMqConnectionFactory _connectionFactory;
        private IChannel? _channel;
        private readonly Task _connectionBuildingTask;

        protected string QueueName { get; init; }

        #region Init

        public MqProducerQueueMode(IRabbitMqConnectionFactory connectionFactory, string queueName)
        {
            _connectionFactory = connectionFactory;
            QueueName = queueName;

            _connectionBuildingTask = BuildConnectionAsync();
            _connectionBuildingTask.SafeFireAndForget(OnCompleted, OnError);
        }

        private void OnError(Exception exception)
        {
            Log4Logger.Logger.Error($"RabbitMQ QueueMode Producer initialized failed.", exception);
        }

        private void OnCompleted()
        {
            Log4Logger.Logger.Info($"RabbitMQ QueueMode Producer initialized successfully.");
        }

        private async Task BuildConnectionAsync()
        {
            var connection = await _connectionFactory.GetConnectionAsync();
            _channel = await connection.CreateChannelAsync();

            await _channel.QueueDeclareAsync(QueueName, true, false, false);
        }

        #endregion Init

        public async Task ProduceAsync(TPayload messagePayload, CancellationToken ct = default)
        {
            ArgumentNullException.ThrowIfNull(messagePayload);

            await _connectionBuildingTask;

            var properties = new BasicProperties
            {
                Persistent = true
            };

            try
            {
                var jsonMsg = JsonSerializer.Serialize(messagePayload);
                byte[] msgBody = Encoding.UTF8.GetBytes(jsonMsg);
                await _channel!.BasicPublishAsync(exchange: string.Empty,
                    routingKey: QueueName,
                    mandatory: true,
                    basicProperties: properties,
                    body: msgBody,
                    cancellationToken: ct
                );
            }
            catch (PublishException pex)
            {
                Log4Logger.Logger.Error(pex);
                throw;
            }
            catch (Exception e)
            {
                Log4Logger.Logger.Error(e);
                throw;
            }
        }
    }
}
