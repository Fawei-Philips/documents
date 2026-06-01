using System.Diagnostics;
using Utils.Events;
using Utils.Tasking;

namespace LeetCode.task
{
    public class TaskTimeout
    {
        public TaskTimeout() { }

        public async Task HandleTaskTimeoutAsync()
        {
            using var cts = new CancellationTokenSource();
            var task = HeavyJob(cts.Token);

            var sw = Stopwatch.StartNew();

            await task.TimeoutAsync(TimeSpan.FromSeconds(3), cts);

            LogEvents.Publish($"Task completed. {task.Status}, spends:{sw.ElapsedMilliseconds}");

        }


        public async Task FooAsync()
        {
            using var cts = new CancellationTokenSource();
            var task = HeavyJob(cts.Token);
            await TimeoutAfter(task, TimeSpan.FromSeconds(10), cts);
        }

        private async Task HeavyJob(CancellationToken token)
        {
            try
            {
                LogEvents.Publish($"HeavyJob Started.");
                // 模拟一个耗时的任务
                await Task.Delay(5000, token);
                LogEvents.Publish($"HeavyJob Completed.");
            }
            catch(OperationCanceledException ex)
            {
                LogEvents.Publish($"HeavyJob was cancelled: {ex.Message}");
            }
            catch (Exception ex)
            {
                LogEvents.Publish($"HeavyJob error occurred: {ex.Message}");
            }
        }


        private async Task TimeoutAfter(Task task, TimeSpan timeSpan, CancellationTokenSource cts)
        {
            try
            {
                await task.WaitAsync(timeSpan);
                LogEvents.Publish($"Task completed. {task.Status}");
            }
            catch (TimeoutException)
            {
                cts.Cancel();
                LogEvents.Publish($"Task cancelled. {task.Status}");
            }
        }
    }
}
