using Utils.Generic;

namespace Utils.Events
{
    public static class LogEvents
    {
        public static event EventHandler<LogEventArgs>? PrintLogEvent;

        public static void Subscribe(EventHandler<LogEventArgs> handler)
        {
            PrintLogEvent += handler;
        }



        public static void Publish(object? sender, LogEventArgs e)
        {
            PrintLogEvent?.Invoke(sender, e);
        }

        public static void Publish(string message)
        {
            var e = new LogEventArgs
            {
                Message = $"[{Environment.CurrentManagedThreadId}]{message} - Time={DatetimeUtil.GetNow()}",
            };
            PrintLogEvent?.Invoke(null, e);
        }

        public static void Publish(object? sender, string message)
        {
            var e = new LogEventArgs
            {
                Items = new Dictionary<string, object>(),
                Message = $"[{Environment.CurrentManagedThreadId}]{message ?? sender?.GetType()?.Name} - Time={DatetimeUtil.GetNow()}",
            };
            PrintLogEvent?.Invoke(sender, e);
        }
    }

    public class LogEventArgs
    {
        public LogEventArgs()
        {
        }

        public LogEventArgs(string? log)
        {
            Message = log;
        }

        public string? Message { get; init; }
        public Dictionary<string, object>? Items { get; set; }
    }
}
