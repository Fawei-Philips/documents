using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeetCode.strings
{
    public class KMP
    {
        public KMP() 
        {
            string text = "ababcabcabababd345";
            string pattern = "ababd";
            int[] kmpNextArr = BuildNextArr(pattern);
            var charText = text.ToCharArray();
            var charPattern = pattern.ToCharArray();
            int index = KmpSearch(charText, charPattern, kmpNextArr);
            Debug.WriteLine($"Pattern found at index: {index}");
        }

        private int KmpSearch(char[] textArr, char[] charPattern, int[] kmpNextArr)
        {
            int i=0 , j = 0;
            while (i < textArr.Length && j < charPattern.Length)
            {
                if (j == -1 || textArr[i] == charPattern[j])
                {
                    i++;
                    j++;
                }
                else
                {
                    j = kmpNextArr[j]; // 回溯到上一个最长前缀
                }
            }

            if (j == charPattern.Length) // 找到匹配
            {
                return i - j; // 返回匹配的起始位置
            }
            return -1; // 如果没有找到匹配，返回 -1
        }

        private int[] BuildNextArr(string pattern)
        {
            int[] nextArr = new int[pattern.Length];
            nextArr[0] = -1; // 第一个字符的前缀表为 -1
            int i = 0;  // 模式串指针
            int j = -1; // next数组指针

            while (i < pattern.Length)
            {
                if (j == -1)
                {
                    i++;
                    j++;
                }
                else if (pattern[i] == pattern[j])
                {
                    i++;
                    j++;
                    nextArr[i] = j; // 更新next数组
                }
                else
                {
                    j = nextArr[j]; // 回溯到上一个最长前缀
                }
            }

            return nextArr;
        }
    }
}
