using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using Utils.Events;

namespace LeetCode.task
{
    public class AsyncTest
    {
        public AsyncTest()
        {
        }

        #region For

        public void TestAsyncFor()
        {
            for (int i = 0; i < 300; i ++)
            {
                var task = Task.Run(() =>
                {
                    Debug.WriteLine($"Task {i} started.");
                    Debug.WriteLine($"Task {i} completed.");
                });
            }
        }

        #endregion For

        #region await

        public void Bootstrap()
        {
            LogEvents.Publish($"[1]Bootstrap Start");
            var task = TestAwaitAsync();
            LogEvents.Publish($"[8]Bootstrap End");
        }

        public void TestWait()
        {
            LogEvents.Publish($"[1]TestWait Start");
            var task1 = HeavyJobAsync();
            var task2 = TaskRunHeavyJobAsync();
            Task.Run(() => 
            {
                LogEvents.Publish($"[8]WaitAll Start");
                Task.WaitAll(task1, task2);
                LogEvents.Publish($"[9]WaitAll End");
            });
        }

        public void TestConfigAwait()
        {
            LogEvents.Publish($"[1]TestWait Start");
            var task1 = HeavyJobAsync();
            var task2 = TaskRunHeavyJobAsync();
            Task.Run(() =>
            {
                LogEvents.Publish($"[8]WaitAll Start");
                Task.WaitAll(task1, task2);
                LogEvents.Publish($"[9]WaitAll End");
            });

            LogEvents.Publish($"[10]all  End");
        }

        public async Task TestAwaitAsync()
        {
            LogEvents.Publish($"[2]Before HeavyJobAsync");
            await HeavyJobAsync();
            LogEvents.Publish($"[5]Take a rest!");
            await Task.Run(TaskRunHeavyJobAsync);
        }

        private async Task HeavyJobAsync()
        {
            LogEvents.Publish($"[3]HeavyJob start!");
            await Task.Delay(1000);
            LogEvents.Publish($"[4]HeavyJob done!");
        }

        private async Task TaskRunHeavyJobAsync()
        {
            LogEvents.Publish($"[6]TaskRunHeavyJobAsync start!");
            await Task.Delay(1000);
            LogEvents.Publish($"[7]TaskRunHeavyJobAsync done!");
        }

        #endregion await

        #region UI thread deadlock

        public void TestUIThreadDeadlockAsync()
        {
            HeavyJobAsync02().Wait();
            LogEvents.Publish($"[3]TaskRunHeavyJobAsync done!");
        }

        private async Task HeavyJobAsync02()
        {
            LogEvents.Publish($"[1]HeavyJobAsync02 start!");
            await Task.Delay(2000).ConfigureAwait(false);
            LogEvents.Publish($"[2]HeavyJobAsync02 done!");
        }

        #endregion UI thread deadlock
    }
}
