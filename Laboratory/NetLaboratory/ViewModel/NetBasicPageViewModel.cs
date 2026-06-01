using CommunityToolkit.Mvvm.Input;
using LeetCode.task;
using NetLaboratory.Knowledge.netBasic;
using System;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Utils.Wpf;

namespace NetLaboratory.ViewModel
{
    public class NetBasicPageViewModel : NotifyChanged
    {
        #region Properties

        public ICommand RefOutCommand { get; }

        #endregion Properties

        public NetBasicPageViewModel()
        {
            RefOutCommand = new RelayCommand(ExecuteRefOut);
        }


        #region Actions

        private void ExecuteRefOut()
        {
            var refout = new RefOut();
            refout.RunStruct();
            refout.RunClass();
        }
        #endregion Actions
    }
}
