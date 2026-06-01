using System.Collections.ObjectModel;

namespace WpfControls.ContextMenu
{
    public interface IContextMenu
    {
        ObservableCollection<IContextMenuItem>? ContextMenus { get; set; }
        //IContextMenuItem? GetContextMenuItem(string key);
        //void AddMenuItem(IContextMenu contextMenu);
        //bool RemoveMenuItem(IContextMenu contextMenu);
    }
}
