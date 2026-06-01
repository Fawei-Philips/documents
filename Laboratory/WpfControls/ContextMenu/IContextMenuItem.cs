using System.Windows.Input;

namespace WpfControls.ContextMenu
{
    public interface IContextMenuItem
    {
        public string Header { get; set; }
        public ICommand Command { get; set; }
        public object? CommandParameter { get; set; }
    }
}
