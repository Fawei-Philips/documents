using Microsoft.AspNetCore.Http;

namespace NetUtils.Aspnet.Generic
{
    public static class HttpContextExtension
    {
        extension(IHttpContextAccessor httpContextAccessor)
        {
            public bool TryGetValue<T>(string key, out T? value) where T : class
            {
                var httpContext = httpContextAccessor.HttpContext;
                if (httpContext == null)
                {
                    value = null;
                    return false;
                }
                if (string.IsNullOrEmpty(key))
                {
                    value = null;
                    return false;
                }

                if (httpContext?.Items == null)
                {
                    value = null;
                    return false;
                }

                var target = httpContext!.Items.TryGetValue(key, out var valueFromItems) ? valueFromItems : null;
                value = target as T;
                return value != null;
            }

            public string? GetString(string key)
            {
                httpContextAccessor.TryGetValue(key, out string? value);
                return value;
            }
        }
    }
}
