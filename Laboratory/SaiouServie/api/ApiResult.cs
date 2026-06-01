namespace SaiouService.api
{
    public class ApiResult<T>
    {
        private int code;
        public int Code { get { return code; } set { code = value; } }


        private string msg;
        public string Msg { get { return msg; } set { msg = value; } }

        private T data;
        public T Data { get { return data; } set { data = value; } }

        private bool success;
        public bool Success { get { return success; } set { success = value; } }

    }
}
