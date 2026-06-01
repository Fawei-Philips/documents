using ImageToXaml.services;
using ImageToXaml.viewmodels;
using Microsoft.Extensions.DependencyInjection;
using System.Windows;

namespace ImageToXaml
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private readonly IServiceProvider _serviceProvider;

        public App()
        {
            var services = new ServiceCollection();

            services.AddSingleton<IFileDialogService, FileDialogService>();
            services.AddTransient<ConverterViewModel>();
            services.AddTransient<MainWindow>();
            _serviceProvider = services.BuildServiceProvider();
        }

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            // 4. Resolve and show the main window
            var mainWindow = _serviceProvider.GetRequiredService<MainWindow>();
            mainWindow.Show();

        }
    }

}
