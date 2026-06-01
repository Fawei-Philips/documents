using CommunityToolkit.Mvvm.Input;
using ImageToXaml.services;
using Microsoft.Win32;
using System.Windows;
using System.Windows.Input;

namespace ImageToXaml.viewmodels
{
    public partial class ConverterViewModel
    {
        private readonly IFileDialogService _fileDialogService;
        public ICommand? OpenSingleFileCommand { get; private set; }

        private string? _inputPath;
        public string? InputPath
        {
            get => _inputPath;
            set
            {
                if (value == _inputPath)
                {
                    return;
                }
                _inputPath = value;
                NotifyUI(() => InputPath);
                OnInputPathChanged();
                (ConvertCommand as RelayCommand)?.NotifyCanExecuteChanged();
            }
        }

        private string? _outputPath;
        public string? OutputPath
        {
            get => _outputPath;
            set
            {
                _outputPath = value;
                NotifyUI(() => OutputPath);

            }
        }

        private void InitFileDialog()
        {
            OpenSingleFileCommand = new RelayCommand<string>(OpenFile);
        }

        private void OpenFile(string fileDialogType)
        {
            var filePath = _fileDialogService.OpenFileDialog(
                filter: "SVG and PNG Files|*.svg;*.png",
                title: "Select SVG or PNG File");

            if (string.IsNullOrEmpty(filePath))
            {
                return;
            }

            if (fileDialogType == "In")
            {
                InputPath = filePath;
            }
            else
            {
                OutputPath = filePath;
            }
        }
    }
}
