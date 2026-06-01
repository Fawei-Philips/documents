namespace Utils.Json
{
    public class ApiResponse<T>
    {
        public required T? Data { get; init; }
        public required int Code { get; init; }
        public string? Message { get; init; }
        public bool IsSuccess => Code == 200;

        public static ApiResponse<T> Success(T? data, string message = "Success")
        {
            return new ApiResponse<T> { Code = 200, Message = message, Data = data };
        }

        public static ApiResponse<T> Fail(string message = "Failed", int code = 500)
        {
            return new ApiResponse<T> { Code = code, Message = message, Data = default };
        }
    }
}
