using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Enumerable;

namespace LeetCode.grid
{
    public class ClosestRoutes
    {
        public ClosestRoutes()
        {
            var initialArea = new int[,]
            {
                { 1, 0, 0, 0 },
                { 0, 1, 0, 0 },
                { 0, 0, 1, 0 },
                { 0, 0, 1, 0 }
            };

            //var initialArea = new int[,]
            //{
            //    { 0, 0 },
            //    { 0, 1 },
            //    { 0, 0 },
            //    { 0, 0 }
            // };

            var result = GetClosestSteps(initialArea);
            Debug.WriteLine(result.Print()); 
        }

        private int[,] GetClosestSteps(int[,] initialArea)
        {
            if (initialArea == null)
            {
                throw new ArgumentNullException(nameof(initialArea), "Initial spots cannot be null.");
            }

            var rowCount = initialArea.GetLength(0);
            var colCount = initialArea.GetLength(1);

            if (rowCount <= 1 || colCount <= 1)
            {
                throw new ArgumentOutOfRangeException("Columns and rows must be greater than 1.");
            }

            Debug.WriteLine(initialArea.Print());

            int[,] result = ComputeDistanceBFS(initialArea, rowCount, colCount);

            return result;
        }

        private int[,] ComputeDistanceBFS(int[,] initialArea, int rowCount, int colCount)
        {
            int[,] result = new int[rowCount, colCount];

            Queue<(int, int)> queue = new Queue<(int, int)>();
            // 收集所有起点位置(值为1)作为BFS起点
            for (int i = 0; i < rowCount; i ++)
            {
                for (int j = 0; j < colCount; j ++)
                {
                    if (initialArea[i, j] == 1)
                    {
                        result[i, j] = 0;
                        queue.Enqueue((i , j));
                    }
                    else
                    {
                        result[i, j] = -1;
                    }
                }
            }

            //四个方向: 上下左右
            int[] dx = { -1, 1, 0, 0 };
            int[] dy = { 0, 0, -1, 1 };
            // 多源BFS遍历
            while (queue.Count > 0)
            {
                var (centerX, centerY) = queue.Dequeue();
                for (int d = 0; d < 4; d ++)
                {
                    int nx = centerX + dx[d];
                    if (nx < 0 || nx == rowCount)
                    {
                        continue;
                    }
                    int ny = centerY + dy[d];
                    if (ny < 0 || ny == colCount)
                    {
                        continue;
                    }

                    if (result[nx, ny] == -1)
                    {
                        result[nx, ny] = result[centerX, centerY] + 1;
                        queue.Enqueue((nx, ny));
                        Debug.Print(result.Print());
                        Debug.Print("-----------");
                    }
                }
            }

            return result;
        }

        private int[,] ComputeDistanceMatrix(int[,] initialSpots, int rows, int columns)
        {
            int[,] result = new int[rows, columns];

            for (int r = 0; r < rows; r++)
            {
                for (int c = 0; c < columns; c++)
                {
                    if (initialSpots[r, c] == 1)
                    {
                        result[r, c] = 0; // Starting point
                    }
                    else
                    {
                        // Calculate the closest distance to a spot with value 1
                        int minDistance = int.MaxValue;
                        for (int i = 0; i < rows; i++)
                        {
                            for (int j = 0; j < columns; j++)
                            {
                                if (initialSpots[i, j] == 1)
                                {
                                    int distance = Math.Abs(r - i) + Math.Abs(c - j);
                                    minDistance = Math.Min(minDistance, distance);
                                }
                            }
                        }
                        result[r, c] = minDistance;
                    }
                }
            }

            return result;
        }
    }
}
