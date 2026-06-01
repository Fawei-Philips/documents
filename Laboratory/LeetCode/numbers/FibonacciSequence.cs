using System.Diagnostics;

namespace LeetCode.numbers
{
    public class FibonacciSequence
    {
        private int count = 0;

        public FibonacciSequence()
        {
            var target_1 = GetIndexOf_recursion‌(7); // 13
            //count = 0;
            //var target_2 = GetIndexOf_iterative(7); // 13
            count = 0;
        }


        // ‌Recursive algorithm
        private int GetIndexOf_recursion‌(int index)
        {
            if (index < 2)
            {
                return index;
            }

            var targetMinus1 = GetIndexOf_recursion‌(index - 1);
            var targetMinus2 = GetIndexOf_recursion‌(index - 2);

            Debug.WriteLine($"复杂度: index={index}, count={++count}");
            return targetMinus1 + targetMinus2;
        }

        // Iterative algorithm
        private int GetIndexOf_iterative(int index)
        {
            if (index < 2)
            {
                return index;
            }
            int targetMinus1 = 1, targetMinus2 = 0, target = 0;
            for (int i = 2; i <= index; i++)
            {
                target = targetMinus1 + targetMinus2;
                targetMinus2 = targetMinus1;
                targetMinus1 = target;
                Debug.WriteLine($"复杂度: index={i}, count={++count}");
            }
            return target;

        }
    }
}
