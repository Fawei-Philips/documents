namespace ImageToXaml.services
{
    public interface IFileDialogService
    {
        string? OpenFileDialog(string filter = "Image Files|*.svg;*.png", string title = "Select Image File");
        IEnumerable<string>? OpenMultipleFilesDialog(string filter = "Image Files|*.svg;*.png", string title = "Select Image Files");
    }
}
