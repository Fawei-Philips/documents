using Logging;

namespace Utils.Tasking
{
    public static class AsyncExtenstion
    {

        extension<TResult>(Task<TResult> task) where TResult : notnull
        {
            public async Task<TResult> TimeoutAsync(TimeSpan timeout, CancellationTokenSource cts)
            {
                try
                {
                    return await task.WaitAsync(timeout);
                }
                catch (TimeoutException)
                {
                    Log4Logger.Logger.Warn($"The operation has timed out after {timeout.TotalMilliseconds} milliseconds.");
                    cts.Cancel();
                    return await task;
                }
            }

            public async void SafeFireAndForget(Action<TResult>? onCompleted = null,
                Action<Exception>? onError = null)
            {
                try
                {
                    var result = await task;
                    onCompleted?.Invoke(result);
                }
                catch (Exception ex)
                {
                    onError?.Invoke(ex);
                }
            }
        }

        extension(Task task)
        {
            public async Task TimeoutAsync(TimeSpan timeout, CancellationTokenSource cts)
            {
                try
                {
                    await task.WaitAsync(timeout);
                }
                catch (TimeoutException)
                {
                    Log4Logger.Logger.Warn($"The operation has timed out after {timeout.TotalMilliseconds} milliseconds.");
                    cts.Cancel();
                }
            }

            public async void SafeFireAndForget(Action? onCompleted = null,
                Action<Exception>? onError = null)
            {
                try
                {
                    await task;
                    onCompleted?.Invoke();
                }
                catch (Exception ex)
                {
                    onError?.Invoke(ex);
                }
            }
        }
    }
}
