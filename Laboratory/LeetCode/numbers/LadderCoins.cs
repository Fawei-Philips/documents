using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeetCode.numbers
{
    public class LadderCoins
    {
        public LadderCoins() 
        {
            var rowNum = GetTotalRow(10);
            rowNum = GetTotalRow(11);
            rowNum = GetTotalRow(12);
            rowNum = GetTotalRow(13);
            rowNum = GetTotalRow(14);
            rowNum = GetTotalRow(15);
            rowNum = GetTotalRow(16);
        }

        /*
         * row is even (4) , coin count = (4 + 1) * 4 / 2 = 10
         * row is even (6) , coin count = (6 + 1) * 6 / 2 = 21
         * @
         * @ @
         * @ @ @
         * @ @ @ @
         * @ @ @ @ @ 
         * @ @ @ @ @ @ 
         * 
         * row is odd (3) , coin count = (3 + 1) * 3 / 2 = 6
         * row is odd (5) , coin count = (5 + 1) * 5 / 2 = 15
         * @
         * @ @
         * @ @ @
         * @ @ @ @
         * @ @ @ @ @
         * 
         * row is n, coin count = (n + 1) * n / 2
         * 
         */
        private int GetTotalRow(int totalCoins)
        {
            int row = 0;
            int maxCoins = 0;
            while (maxCoins < totalCoins)
            {
                row++;
                maxCoins = (row + 1) * row / 2;
            }

            return row;
        }
    }
}
