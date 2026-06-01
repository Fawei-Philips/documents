using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Enumerable;

namespace LeetCode.numbers
{
    public class TargetSum
    {
        public TargetSum() 
        {
            var arr = new int[] { 6, 6, 1, 5, 2,7,8,8,3,4 };
            var target = 10;
            var result = GetTargetSumIndex(arr, target);
            // Output the result or use it as needed
        }

        private Dictionary<int, int> GetTargetSumIndex(int[] arr, int sum)
        {
            var result = new Dictionary<int, int>();

            for (int i = 0; i < arr.Length - 1; i++)
            {
                for (int j = i + 1; j < arr.Length; j++)
                {
                    if (arr[i] + arr[j] == sum)
                    {
                        result.AddOrUpdate(arr[i], arr[j]);
                    }
                }
            }
            return result;
        }
    }
}
