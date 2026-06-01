using System.Threading.Channels;
using Utils.Events;

namespace LeetCode.task
{
    public class ChannelDemo
    {
        public async Task RunAsync()
        {
            var msgChannel = Channel.CreateUnbounded<Message>();

            var messages1 = Enumerable.Range(1, 30).AsParallel().AsOrdered()
                .Select(i => new Message(i, $"sender1 [{i}]")).ToList();

            var messages2 = Enumerable.Range(1, 30).AsParallel().AsOrdered()
                .Select(i => new Message(i, $"sender2 [{i}]")).ToList();

            var sender1 =  SendMessagesAsync(msgChannel.Writer, messages1);
            var sender2 = SendMessagesAsync(msgChannel.Writer, messages2);

            var receiver1 =  ReceiveMessagesAsync(msgChannel.Reader);
            var receiver2 = ReceiveMessagesAsync(msgChannel.Reader);

            await Task.WhenAll(sender1, sender2);
            msgChannel.Writer.Complete();
            await Task.WhenAll(receiver1, receiver2);

            LogEvents.Publish("ChannelDemo completed.");
        }

        private async Task SendMessagesAsync(ChannelWriter<Message> channelWriter, List<Message> messages) 
        {
            foreach (var message in messages)
            {
                await SendMessageAsync(channelWriter, message);
            }
        }

        private async Task SendMessageAsync(ChannelWriter<Message> channelWriter, Message message)
        {
            await channelWriter.WriteAsync(message);
            LogEvents.Publish($"Sender: {message.Id} Sent.");
            await Task.Delay(200); // Simulate some processing delay
        }

        private async Task ReceiveMessagesAsync(ChannelReader<Message> reader)
        {
            await foreach(var message in reader.ReadAllAsync())
            {
                LogEvents.Publish($"Receiver: {message.Content} Received.");
            }
        }

        private async Task ReceiveMessagesAsyncOld(ChannelReader<Message> reader)
        {
            try
            {
                while (!reader.Completion.IsCompleted)
                {
                    var message = await reader.ReadAsync();
                    LogEvents.Publish($"Receiver: {message.Content} Received.");
                }
            }
            catch (ChannelClosedException ex)
            {
                LogEvents.Publish($"Receiver ChannelClosed: {ex.Message}");
            }
            catch (Exception ex)
            {
                LogEvents.Publish($"Receiver error occurred: {ex.Message}");
            }
        }
    }

    public class Message
    {
        public int Id { get; set; }
        public string Content { get; set; }
        public Message(int id, string content)
        {
            Id = id;
            Content = content;
        }
    }
}
