using System.Diagnostics;
using Utils.Enumerable;

namespace LeetCode.grid
{
    public class BombermanGame
    {
        /*
         * given a initial grid with default bombs (1)
         * 0 represents empty area, no bomb
         * a new bomb a 3 seconds timer tick per second
         * second 1 : nothing happens
         * second 2 : the bomberman fills all grid with bomb (1)
         * second 3 : the bombs explode and nearby area (distence 1) will be replaced with empty area (0) 
         * 
         * request to print the status of the grid when x seconds passed (duration)
         */
        public BombermanGame()
        {
            var initialGrid = new int[,]
            {
                { 0, 0, 0, 0 },
                { 0, 1, 0, 0 },
                { 0, 0, 1, 0 },
                { 0, 0, 1, 0 }
            };

            int duration = 7;

            var result = GridStatus(initialGrid, duration);
            Debug.WriteLine(result.Print());
        }

        private int[,] GridStatus(int[,] initialGrid, int duration)
        {
            var rowCount = initialGrid.GetLength(0);
            var colCount = initialGrid.GetLength(1);

            if (rowCount <= 1 || colCount <= 1)
            {
                throw new ArgumentOutOfRangeException("Columns and rows must be greater than 1.");
            }

            Debug.WriteLine(initialGrid.Print());

            int[,] result = ComputeGridStatus(initialGrid, rowCount, colCount, duration);
            return result;
        }

        private int[,] ComputeGridStatus(int[,] initialGrid, int rowCount, int colCount, int duration)
        {
            // If duration % 4 = 1, return the initial grid as it is
            if (duration % 4 == 1)
            {
                return initialGrid;
            }

            var fullGrid = GetGridForEvenSeconds(rowCount, colCount);
            // If duration is even, the grid will be filled with bombs
            if (duration % 2 == 0)
            {
                return fullGrid;
            }

            // If duration % 4 = 3, we need to simulate the explosion
            Queue<(int, int)> currentBombs = new Queue<(int, int)>();

            // Initialize the queue with the initial bombs
            for (int i = 0; i < rowCount; i++)
            {
                for (int j = 0; j < colCount; j++)
                {
                    if (initialGrid[i, j] == 1)
                    {
                        currentBombs.Enqueue((i, j));
                    }
                }
            }

            // up, down, left, right
            var dx = new int[] { -1, 1, 0, 0 };
            var dy = new int[] { 0, 0, -1, 1 };
            while (currentBombs.Count > 0)
            {
                // Process the current bombs
                var (currentX, currentY) = currentBombs.Dequeue();
                for (int d = 0; d < 4; d++)
                {
                    var targetX = currentX + dx[d];
                    if (targetX < 0 || targetX == rowCount)
                    {
                        continue;
                    }
                    var targetY = currentY + dy[d];
                    if (targetY < 0 || targetY == colCount)
                    {
                        continue;
                    }

                    ClearBomb(fullGrid, currentX, currentY);
                    ClearBomb(fullGrid, targetX, targetY);

                    Debug.WriteLine(fullGrid.Print());
                    Debug.WriteLine("--------------");
                }
            }
            return fullGrid;
        }

        private static int[,] GetGridForEvenSeconds(int rowCount, int colCount)
        {
            var result = new int[rowCount, colCount];
            for (int i = 0; i < rowCount; i++)
            {
                for (int j = 0; j < colCount; j++)
                {
                    SetBomb(result, i, j);
                }
            }

            return result;
        }

        private static void SetBomb(int[,] grid, int row, int col)
        {
            if (grid[row, col] != 1)
            {
                grid[row, col] = 1;
            }
        }

        private static void ClearBomb(int[,] grid, int row, int col)
        {
            if (grid[row, col] != 0)
            {
                grid[row, col] = 0;
            }
        }
    }

    /*
     simulate
        >>>>s1
                { 0, 0, 0, 0 },
                { 0, 1, 0, 0 },
                { 0, 0, 1, 0 },
                { 0, 0, 1, 0 }
        >>>>s2
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 }
        >>>>s3
                { 1, 0, 1, 1 },
                { 0, 0, 0, 1 },
                { 1, 0, 0, 0 },
                { 1, 0, 0, 0 }
        >>>>s4
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 }
        >>>>s5
                { 0, 0, 0, 0 },
                { 0, 1, 0, 0 },
                { 0, 0, 1, 0 },
                { 0, 0, 1, 0 }
     */
}
