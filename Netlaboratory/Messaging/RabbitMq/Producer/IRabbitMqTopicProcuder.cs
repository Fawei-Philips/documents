using Messaging.RabbitMq.Models;

namespace Messaging.RabbitMq.Producer
{
    public interface IRabbitMqTopicProducer<TPayload> where TPayload : ITopicPayload
    {
        Task ProduceAsync(TPayload messagePayload, CancellationToken ct = default);
    }
}
