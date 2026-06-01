using System.Diagnostics;

namespace LeetCode.strings
{
    public class MinionGame
    {
        public MinionGame()
        {
            Debug.WriteLine("Minion Game");
            string source = "BANANA";
            Play(source);
        }


        private void Play(string source)
        {
            int kevinScore = 0;
            int stuartScore = 0;
            int length = source.Length;
            for (int i = 0; i < length; i++)
            {
                if (source[i] == 'A' || source[i] == 'E' || source[i] == 'I' || source[i] == 'O' || source[i] == 'U')
                {
                    kevinScore += length - i;
                }
                else
                {
                    stuartScore += length - i;
                }
            }

            Debug.WriteLine($"Kevin {kevinScore}");
            Debug.WriteLine($"Stuart {stuartScore}");
        }
    }
}
