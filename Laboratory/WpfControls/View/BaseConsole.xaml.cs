using WpfControls.LogConsole;
using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;

namespace WpfControls.View
{
    /// <summary>
    /// BaseConsole.xaml 的交互逻辑
    /// </summary>
    public partial class BaseConsole : UserControl
    {
        #region Properties

        private static readonly Type ControlType = typeof(BaseConsole);

        public string Title
        {
            get { return (string)GetValue(TitleProperty); }
            set { SetValue(TitleProperty, value); }
        }

        public static readonly DependencyProperty TitleProperty =
            DependencyProperty.Register("Title", typeof(string), ControlType, new PropertyMetadata("Console with Logging"));

        public LogPanel LogPanel
        {
            get { return (LogPanel)GetValue(LogPanelProperty); }
            set { SetValue(LogPanelProperty, value); }
        }

        public static readonly DependencyProperty LogPanelProperty =
            DependencyProperty.Register("LogPanel", typeof(LogPanel), ControlType);

        public StackPanel ConsoleContent
        {
            get { return (StackPanel)GetValue(ConsoleContentProperty); }
            set { SetValue(ConsoleContentProperty, value); }
        }

        public static readonly DependencyProperty ConsoleContentProperty =
            DependencyProperty.Register("ConsoleContent", typeof(StackPanel), ControlType);

        #endregion Properties

        #region Constructor

        public BaseConsole()
        {
            InitializeComponent();
            LogPanel = logPanelCtrl;
        }

        #endregion Constructor

        #region events

        #endregion events
    }
}
