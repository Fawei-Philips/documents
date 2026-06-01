using System.Diagnostics;
using Utils.Enumerable;

namespace LeetCode.logic
{
    public class TurnStile
    {
        public TurnStile()
        {
            // 测试用例
            var time = new List<int> { 0,0,1,5 };
            var direction = new List<int> { 0, 1, 1, 0 };
            var result = GetTimes(time, direction);
            Debug.WriteLine(result.NotNullString());
        }


        private List<int> GetTimes(List<int> time, List<int> direction)
        {
            int n = time.Count;
            List<int> result = new List<int>(new int[n]);
            Queue<int> enterQueue = new Queue<int>(); // 存储方向为0（进入）的人员索引
            Queue<int> exitQueue = new Queue<int>();  // 存储方向为1（退出）的人员索引
            int currentTime = 0;
            int previousDirection = -1; // -1: 未使用过, 0: 上一次是进入, 1: 上一次是退出
            int i = 0;

            while (i < n || enterQueue.Count > 0 || exitQueue.Count > 0)
            {
                // 将当前时间到达的人员加入对应队列
                while (i < n && time[i] == currentTime)
                {
                    if (direction[i] == 0)
                    {
                        enterQueue.Enqueue(i);
                    }
                    else
                    {
                        exitQueue.Enqueue(i);
                    }
                    i++;
                }

                bool processed = false;
                // 根据上一次的方向确定优先处理的队列
                if (previousDirection == -1)
                {
                    // 未使用过，优先处理退出（方向1）
                    if (exitQueue.Count > 0)
                    {
                        int idx = exitQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 1;
                        currentTime++;
                        processed = true;
                    }
                    else if (enterQueue.Count > 0)
                    {
                        int idx = enterQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 0;
                        currentTime++;
                        processed = true;
                    }
                }
                else if (previousDirection == 1)
                {
                    // 上一次是退出，优先处理退出（方向1）
                    if (exitQueue.Count > 0)
                    {
                        int idx = exitQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 1;
                        currentTime++;
                        processed = true;
                    }
                    else if (enterQueue.Count > 0)
                    {
                        int idx = enterQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 0;
                        currentTime++;
                        processed = true;
                    }
                }
                else
                { // previousDirection == 0（上一次是进入）
                  // 优先处理进入（方向0）
                    if (enterQueue.Count > 0)
                    {
                        int idx = enterQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 0;
                        currentTime++;
                        processed = true;
                    }
                    else if (exitQueue.Count > 0)
                    {
                        int idx = exitQueue.Dequeue();
                        result[idx] = currentTime;
                        previousDirection = 1;
                        currentTime++;
                        processed = true;
                    }
                }

                // 若未处理任何人员，推进时间到下一个到达时间
                if (!processed && i < n)
                {
                    currentTime = time[i];
                }
            }

            return result;
        }
    }
}
