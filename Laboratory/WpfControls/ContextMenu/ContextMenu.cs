using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace WpfControls.ContextMenu
{
    public class ContextMenuItem : IContextMenuItem
    {
        public required string Header { get; set; }
        public required ICommand Command { get; set; }
        public object? CommandParameter { get; set; }
    }
}
