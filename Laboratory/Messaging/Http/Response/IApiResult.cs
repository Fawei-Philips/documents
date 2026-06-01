namespace Messaging.Http.Response
{
    public interface IApiResult<TPayload>
    {
        int Code { get; set; }
        string Message { get; set; }
        TPayload Data { get; set; }
    }
}
