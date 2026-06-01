using CommunityToolkit.Mvvm.Input;
using ImageToXaml.services;
using SharpVectors.Converters;
using SharpVectors.Renderers.Wpf;
using System.Windows.Input;
using Utils.Wpf;

namespace ImageToXaml.viewmodels
{
    public partial class ConverterViewModel : NotifyChanged
    {
        #region Properties
        private WpfDrawingSettings _wpfSettings;
        public ICommand ConvertCommand { get; }

        #endregion Properties

        public ConverterViewModel(IFileDialogService fileDialogService)
        {
            _wpfSettings = new WpfDrawingSettings();
            _wpfSettings.IncludeRuntime = false;
            _wpfSettings.TextAsGeometry = false;
            ConvertCommand = new RelayCommand(ConvertImageToXaml, CanExecute);

            _fileDialogService = fileDialogService;
            InitFileDialog();
        }

        private bool CanExecute()
        {
            if (string.IsNullOrEmpty(InputPath))
            {
                return false;
            }

            if (string.IsNullOrEmpty(OutputPath))
            {
                return false;
            }

            return true;
        }

        private void ConvertImageToXaml()
        {
            try
            {
                var converter = new FileSvgConverter(_wpfSettings);
                converter.Convert(InputPath, OutputPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during conversion: {ex.Message}");
                return;
            }
        }

        private void OnInputPathChanged()
        {
            OutputPath = InputPath?.Replace(".svg", ".xaml");
        }
    }
}
