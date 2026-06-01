using ImageToXaml.viewmodels;
using System.Windows;

namespace ImageToXaml
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow(ConverterViewModel converterViewModel)
        {
            InitializeComponent();
            DataContext = converterViewModel;
        }
    }
}