using LeetCode.enumerable;
using LeetCode.numbers;
using LeetCode.numbers.sort;
using LeetCode.strings;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace NetLaboratory.View
{
    /// <summary>
    /// LeetCodeCtrl.xaml 的交互逻辑
    /// </summary>
    public partial class LeetCodeCtrl : UserControl
    {
        public LeetCodeCtrl()
        {
            InitializeComponent();
        }


        private void PrimeCounter_Click(object sender, RoutedEventArgs e)
        {
            new PrimeCounter();
        }

        private void DuplicateRemoval_Click(object sender, RoutedEventArgs e)
        {
            new DuplicateRemoval();
        }

        private void CenterIndex_Click(object sender, RoutedEventArgs e)
        {
            new CenterIndex();
        }

        private void TargetSum_Click(object sender, RoutedEventArgs e)
        {
            new TargetSum();
        }

        private void AsyncTest_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.task.AsyncTest();
        }

        private void FibonacciSequence_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.numbers.FibonacciSequence();
        }

        private void LadderCoins_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.numbers.LadderCoins();
        }

        private void CollectionInstructions_Click(object sender, RoutedEventArgs e)
        {
            new CollectionInstructions();
        }

        private void MinionGame_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.strings.MinionGame();
        }

        private void ClosestRoutes_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.grid.ClosestRoutes();
        }

        private void Bomberman_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.grid.BombermanGame();
        }

        private void PhoneNumberComb_Click(object sender, RoutedEventArgs e)
        {
            new PhoneNumberComb();
        }

        private void KMP_Click(object sender, RoutedEventArgs e)
        {
            new KMP();
        }

        private void TurnStile_Click(object sender, RoutedEventArgs e)
        {
            new LeetCode.logic.TurnStile();
        }

        private void SortTest_Click(object sender, RoutedEventArgs e)
        {
            new SortTest();
        }

        private void InterviewTest_Click(object sender, RoutedEventArgs e)
        {
            new InterviewTest();
        }
    }
}
