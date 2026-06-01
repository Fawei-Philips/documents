using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeetCode.strings
{
    public class InterviewTest
    {
        /*

         Input "hello, world, I am happy today"
        Output "yadot yppah ma I ,dlrow ,olleh"
        Output 2: "today happy am I, world, hello"
        Output 3 "olleh, dlrow, I ma yppah yadot"

         */

        public InterviewTest()
        {
            var input = "hello, world, I am happy today";
            var res1 = Test1(input, ' ');

        }

        private string Test1(string input, char separater)
        {
            if (string.IsNullOrEmpty(input))
            {
                return input;
            }

            var stack = new Stack<string>();
            var splits = Spliter(input,separater);
            foreach (var split in splits)
            {
                var reversedStr = ReverseSingleStr(split);
                stack.Push(reversedStr);
            }
            var result = string.Empty;

            while (stack.Count > 0)
            {
                result += stack.Pop() + " ";
            }

            return result;
        }
            
        private string Test3(string input)
        {
            return null;
        }

        private string[] Spliter(string input, char separator)
        {
            if (string.IsNullOrEmpty(input))
            {
                throw new ArgumentException("input is invalid");
            }

            var stack = new Stack<string>();
            var splits = input.Split(separator);

            return splits;
        }

        private string ReverseSingleStr(string input)
        {
            var chars = input.ToCharArray();

            var revrse = chars.Reverse().ToArray();
            return new string(revrse);

            //int left = 0;
            //int right = chars.Length - 1;
            //while (left < right)
            //{
            //    Swap(chars, left, right);
            //    left++;
            //    right--;
            //}
            //return new string(chars);
        }

        private static void Swap(char[] chars, int left, int right)
        {
            left = left ^ right;
            right = left ^ right;
            left = left ^ right;
        }

    }
}
