namespace Messaging.Http.Response
{
    public class CommandData<TPayload> where TPayload : class
    {
        public required string Command { get; set; }
        public bool Success { get; set; }
        public string? Message { get; set; }
        public required TPayload Data { get; set; }
    }
}
