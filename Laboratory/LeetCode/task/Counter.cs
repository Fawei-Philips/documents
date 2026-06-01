using System.Diagnostics;
using Utils.Events;

namespace LeetCode.task
{
    public class Counter
    {
        public int Count { get; private set; } = 0;
        private static int StaticCount = 0;

        public Counter()
        {

        }

        public void Show()
        {
            Task.Run(() =>
            {
                Increment();
            });

            Task.Run(() =>
            {
                Increment();
            });
        }

        public void StaticShow()
        {
            Task.Run(() =>
            {
                StaticIncrement();
            });

            Task.Run(() =>
            {
                StaticIncrement();
            });
        }

        private void Increment()
        {
            for (int i = 0; i < 10000; i++)
            {
                Count++;
            }
            LogEvents.Publish($"[{Environment.CurrentManagedThreadId}]Count after increment: {Count}");
        }

        private void StaticIncrement()
        {
            for (int i = 0; i < 10000; i++)
            {
                StaticCount++;
            }
            LogEvents.Publish($"[{Environment.CurrentManagedThreadId}]StaticCount after increment: {StaticCount}");
        }
    }
}
