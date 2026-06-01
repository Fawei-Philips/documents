using MaterialDesignThemes.Wpf;
using System.Windows;
using System.Windows.Controls;

namespace WpfWidgets.popup
{
    public partial class NotificationBar : UserControl
    {

        public SnackbarMessageQueue MessageQueue    
        {
            get { return (SnackbarMessageQueue)GetValue(MessageQueueProperty); }
            set { SetValue(MessageQueueProperty, value); }
        }

        public static readonly DependencyProperty MessageQueueProperty =
            DependencyProperty.Register("MessageQueue", typeof(SnackbarMessageQueue), typeof(NotificationBar));

        public NotificationBar()
        {
            InitializeComponent();
        }
    }
}
