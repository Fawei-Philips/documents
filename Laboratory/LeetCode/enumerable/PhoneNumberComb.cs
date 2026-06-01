using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Enumerable;

namespace LeetCode.enumerable
{
    public class PhoneNumberComb
    {
        /*
         * 电话号码组合
         * 给定一个仅包含数字 2-9 的字符串，返回所有它能表示的字母组合。答案可以按 任意顺序 返回。
         * 每个字母对应于电话键盘上的数字，数字 2 对应于 "abc"，数字 3 对应于 "def"，依此类推。
         */
        public PhoneNumberComb()
        {
            string digits = "239";
            IList<string> combinations = LetterCombinations(digits);
            Debug.WriteLine(combinations.NotNullString());
        }

        // 定义数字到字母的映射
        private static Dictionary<char, string> digitMap = new Dictionary<char, string>()
            {
                {'2', "abc"}, {'3', "def"}, {'4', "ghi"}, {'5', "jkl"},
                {'6', "mno"}, {'7', "pqrs"}, {'8', "tuv"}, {'9', "wxyz"}
            };

        static IList<string> LetterCombinations(string digits)
        {
            IList<string> result = new List<string>();
            if (string.IsNullOrEmpty(digits))
            {
                return result;
            }
            // 回溯函数
            Backtrack(digits, 0, "", result);
            return result;
        }

        static void Backtrack(string digits, int index, string current, IList<string> result)
        {
            // 递归终止条件：已经处理完所有数字
            if (index == digits.Length)
            {
                result.Add(current);
                return;
            }
            char digit = digits[index];
            string letters = digitMap[digit];
            // 遍历当前数字对应的所有字母
            foreach (char letter in letters)
            {
                // 选择当前字母，进入下一层递归
                Backtrack(digits, index + 1, current + letter, result);
            }
        }
    }
}
