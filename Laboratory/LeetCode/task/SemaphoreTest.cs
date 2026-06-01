using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Events;

namespace LeetCode.task
{
    public class SemaphoreTest
    {
        private IEnumerable<int> numbers = Enumerable.Range(1, 20);

        //Semaphore 可以实现进程之间限流
        private SemaphoreSlim semaphore = new SemaphoreSlim(3, 3); // Limit to 3 concurrent tasks 

        public void Run()
        {
            var sw = Stopwatch.StartNew();
            var outputs = numbers.AsParallel()
                .AsOrdered()
                .Select(HeavyJob).ToArray();

            LogEvents.Publish($"Outputs:[{string.Join(",", outputs)}]");
            LogEvents.Publish($"Elapsed: {sw.ElapsedMilliseconds} ms");
        }

        private int HeavyJob(int number)
        {
            semaphore.Wait();
            // Simulate a heavy job
            Task.Delay(300).Wait();
            semaphore.Release();
            return number * number;
        }
    }
}
