using Microsoft.Win32;

namespace ImageToXaml.services
{
    public class FileDialogService : IFileDialogService
    {
        public string? OpenFileDialog(string filter = "Image Files|*.svg;*.png", string title = "Select Image File")
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = filter,
                Title = title,
                Multiselect = false
            };

            return openFileDialog.ShowDialog() == true ? openFileDialog.FileName : null;
        }

        public IEnumerable<string>? OpenMultipleFilesDialog(string filter = "Image Files|*.svg;*.png", string title = "Select Image Files")
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = filter,
                Title = title,
                Multiselect = true
            };

            return openFileDialog.ShowDialog() == true ? openFileDialog.FileNames : null;
        }
    }
}
