using System.Diagnostics;
using Utils.Enumerable;

namespace LeetCode.logic
{
    public class StaleServer
    {
        public StaleServer() 
        {
            int n = 5;
            List<List<int>> log_data = new List<List<int>>
            {
                new List<int> { 1, 1 },
                new List<int> { 2, 2 },
                new List<int> { 3, 3 },
                new List<int> { 4, 4 },
                new List<int> { 5, 5 },
                new List<int> { 1, 6 },
                new List<int> { 2, 7 }
            };
            List<int> query = new List<int> { 6, 7 };
            int x = 2;
            var result = getStaleServerCount(n, log_data, query, x);
            Debug.WriteLine(result.NotNullString());
        }

        public List<int> getStaleServerCount(int n, List<List<int>> log_data, List<int> query, int x)
        {
            List<int> results = new List<int>();

            foreach (int q in query)
            {
                int start = q - x;
                int end = q;
                HashSet<int> activeServers = new HashSet<int>();

                foreach (List<int> entry in log_data)
                {
                    int serverId = entry[0];
                    int time = entry[1];

                    if (time >= start && time <= end)
                    {
                        activeServers.Add(serverId);
                    }
                }

                // 未收到请求的服务器数量 = 总服务器数 - 有请求的服务器数
                results.Add(n - activeServers.Count);
            }

            return results;
        }
    }
}
