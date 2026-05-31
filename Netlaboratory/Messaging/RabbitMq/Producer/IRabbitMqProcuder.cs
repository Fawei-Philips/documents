namespace Messaging.RabbitMq.Producer
{
    public interface IRabbitMqProducer<TPayload>
    {
        Task ProduceAsync(TPayload messagePayload, CancellationToken ct = default);
    }
}
