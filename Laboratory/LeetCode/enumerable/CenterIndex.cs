using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Enumerable;

namespace LeetCode.enumerable
{
    public class CenterIndex
    {
        public CenterIndex() 
        {
            var arr = new int[] { 1, 7, 3, 6, 5, 6 };
            var result = GetCenterIndex(arr);
        }

        private int GetCenterIndex(int[] arr)
        {
            if (!arr.HasItem())
            {
                return -1;
            }

            var rightSum = arr.Sum();
            int leftSum = 0;
            for (int i = 0; i < arr.Length; i++)
            {
                leftSum += arr[i];
                if (leftSum == rightSum)
                {
                    return i;
                }
                rightSum -= arr[i];
            }

            return -1;
        }
    }
}
