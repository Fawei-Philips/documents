using Logging;
using System.Configuration;
using System.Data;
using System.Windows;

namespace NetLaboratory
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            log4net.Config.XmlConfigurator.Configure();
        }
    }

}
