using System.Diagnostics;
using Utils.Enumerable;

namespace LeetCode.numbers.sort
{
    public class SelectionSort
    {   
        public SelectionSort()
        {
            var arrToSort = new int[] { 5, 2, 3, 1, 4, 90, 21 };
            Sort(arrToSort);

            var strResult = arrToSort.Print();
            Debug.WriteLine(strResult);
        }


        private void Sort(int[] ints)
        {
            if (!ints.HasItem() || ints.Length == 1)
            {
                return;
            }

            for (int i = 0; i < ints.Length - 1; i ++)
            {
                int minIndex = i;
                for (int j = i + 1; j < ints.Length; j ++)
                {
                    if (ints[j] < ints[minIndex])
                    {
                        minIndex = j;
                    }
                }
                Swap(ints, i, minIndex);
            }
        }

        private void Swap(int[] ints, int i, int j)
        {
            var tmp = ints[i];
            ints[i] = ints[j];
            ints[j] = tmp;
            //ints[i] = ints[i] ^ ints[j];
            //ints[j] = ints[i] ^ ints[j];
            //ints[i] = ints[i] ^ ints[j];
        }
    }
}
