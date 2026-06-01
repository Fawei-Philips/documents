# The package provides custom UI components for WPF applications.

## NotificationBar

To use the `NotificationBar` component in your WPF application, first add the following namespace declaration to your XAML file:
``` xaml
xmlns:popup="clr-namespace:WpfWidgets.popup;assembly=WpfWidgets"


<popup:NotificationBar VerticalAlignment="Center"
                        MessageQueue="{Binding MessageQueue}"
                        FontSize="26">

</popup:NotificationBar>
```
``` Csharp
// Bind the MessageQueue property to an instance of SnackbarMessageQueue in your ViewModel:
[ObservableProperty]
ISnackbarMessageQueue _messageQueue = new SnackbarMessageQueue();
```