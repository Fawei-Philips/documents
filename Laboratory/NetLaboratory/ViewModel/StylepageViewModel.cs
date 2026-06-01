using CommunityToolkit.Mvvm.Input;
using System.Collections.ObjectModel;
using System.Windows.Input;
using WpfControls.MaterialDesign.Buttons;

namespace NetLaboratory.ViewModel
{
    public partial class StylePageViewModel
    {
        public ThemableButtonViewModel PrimaryButton { get; }
        public ObservableCollection<ThemableButtonViewModel> Buttons { get; }

        // 动态按钮的ViewModel
        public ThemableButtonViewModel DynamicButton { get; }

        // 切换动态按钮类型的命令
        public ICommand SwitchDynamicButtonTypeCommand { get; }

        private int _currentTypeIndex = 0;
        private readonly ButtonType[] _buttonTypes = (ButtonType[])System.Enum.GetValues(typeof(ButtonType));

        public StylePageViewModel()
        {
            // 初始化单个按钮
            PrimaryButton = new ThemableButtonViewModel(
                content: "主要操作",
                buttonType: ButtonType.Primary,
                clickAction: ExecutePrimary
            );
            // 初始化按钮集合
            Buttons = new ObservableCollection<ThemableButtonViewModel>
            {
                // 添加带不同行为的按钮
                new ThemableButtonViewModel("保存数据", ButtonType.Primary, "userdata", HandleSave),
                new ThemableButtonViewModel("取消操作", ButtonType.Secondary, null, HandleCancel),
                new ThemableButtonViewModel("删除记录", ButtonType.Danger, 123, HandleDelete),
                new ThemableButtonViewModel("操作成功", ButtonType.Success, "completed", HandleSuccess),
                new ThemableButtonViewModel("显示信息", ButtonType.Info, "help", HandleInfo)
            };

            // 初始化动态按钮
            DynamicButton = new ThemableButtonViewModel("动态按钮", ButtonType.Primary, "dynamic", HandleDynamic);

            // 初始化切换命令
            SwitchDynamicButtonTypeCommand = new RelayCommand<object>(HandleSwitchDynamicButtonType);
        }

        private void ExecutePrimary(ThemableButtonViewModel button)
        {
        }

        // 各种按钮的处理逻辑
        private void HandleSave(ThemableButtonViewModel button)
        {
            System.Windows.MessageBox.Show($"执行保存操作，参数: {button.ActionParameter}", "操作提示");
        }

        private void HandleCancel(ThemableButtonViewModel button)
        {
            System.Windows.MessageBox.Show("执行取消操作", "操作提示");
        }

        private void HandleDelete(ThemableButtonViewModel button)
        {
            if (System.Windows.MessageBox.Show("确定要删除吗？", "确认",
                System.Windows.MessageBoxButton.YesNo) == System.Windows.MessageBoxResult.Yes)
            {
                System.Windows.MessageBox.Show($"执行删除操作，ID: {button.ActionParameter}", "操作提示");
            }
        }

        private void HandleSuccess(ThemableButtonViewModel button)
        {
            System.Windows.MessageBox.Show("操作已成功完成", "操作提示");
        }

        private void HandleInfo(ThemableButtonViewModel button)
        {
            System.Windows.MessageBox.Show($"信息: {button.ActionParameter}", "操作提示");
        }

        private void HandleDynamic(ThemableButtonViewModel button)
        {
            System.Windows.MessageBox.Show($"动态按钮点击，当前类型: {button.ButtonType}", "操作提示");
        }

        // 切换动态按钮类型
        private void HandleSwitchDynamicButtonType(object? parameter)
        {
            _currentTypeIndex = (_currentTypeIndex + 1) % _buttonTypes.Length;
            DynamicButton.ButtonType = _buttonTypes[_currentTypeIndex];
            DynamicButton.Content = $"动态按钮 ({DynamicButton.ButtonType})";
        }
    }
}
