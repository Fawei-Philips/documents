using System.Collections.Generic;
using System.Text;

namespace Utils.Enumerable
{
    public static class ArrayExt
    {
        /// <summary>
        /// 打印一维或多维数组到控制台
        /// </summary>
        public static string? Print(this Array array, char separator = ' ')
        {
            if (array == null || array.Length < 2)
            {
                return array?.GetValue(0)?.ToString();
            }

            int rank = array.Rank;
            var sb = new StringBuilder();
            if (rank == 1)
            {
                var first = array.GetValue(0);
                for (int i = 0; i < array.Length - 1; i ++)
                {
                    sb.Append(array.GetValue(i));
                    sb.Append(separator);
                }

                sb.Append(array.GetValue(array.Length - 1));
                return sb.ToString();
            }
            else if (rank == 2)
            {
                int rows = array.GetLength(0);
                int cols = array.GetLength(1);
                for (int i = 0; i < rows; i++)
                {
                    for (int j = 0; j < cols; j++)
                    {
                        sb.Append(array.GetValue(i, j));
                        if (j < cols - 1)
                        {
                            sb.Append(separator);
                        }
                    }
                    if (i < rows - 1)
                    {
                        sb.AppendLine();
                    }
                }

                return sb.ToString();
            }
            else
            {
                return "Array rank > 2 is not support";
            }
        }
    }
}
