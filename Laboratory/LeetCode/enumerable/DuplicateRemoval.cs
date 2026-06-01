namespace LeetCode.enumerable
{
    public class DuplicateRemoval
    {
        public DuplicateRemoval() 
        {
            var arr = new int[] { 5, 6, 7, 8, 1, 2, 3, 4, 5, 9, 9, 10 };
            RemoveDuplicates(arr);
        }

        /// <summary>
        /// Use LINQ to remove duplicates from an array of integers.
        /// </summary>
        /// <param name="arr"></param>
        /// <returns></returns>
        public int[] RemoveDuplicatesByLinq(int[] arr)
        {
            var sortedArr = arr.Order();
            var distinctArr = sortedArr.Distinct().ToArray();

            return distinctArr;
        }


        public int[] RemoveDuplicates(int[] arr)
        {
            var sortedArr = arr.Order().ToArray();
            var distinctArr = new List<int>();

            int j = 0;
            for(int i = 0; i < sortedArr.Length; i=j)
            {
                distinctArr.Add(sortedArr[i]);

                j = i + 1;
                if (j == sortedArr.Length)
                {
                    break;
                }

                while (sortedArr[i] == sortedArr[j])
                {
                    j++;
                    if (j == sortedArr.Length)
                    {
                        break;
                    }
                }
            }

            return distinctArr.ToArray();
        }
    }
}
