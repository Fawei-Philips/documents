using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MaterialDesignThemes.Wpf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetLaboratory.ViewModel
{
    public partial class WidegtsViewModel : ObservableObject
    {
        #region SnackBar

        [ObservableProperty]
        private string? _snackBarMessage;

        [ObservableProperty]
        ISnackbarMessageQueue _messageQueue = new SnackbarMessageQueue();

        [RelayCommand]
        private void SendMessage()
        {
            MessageQueue.Enqueue(SnackBarMessage);
        }

        #endregion SnackBar
    }
}
