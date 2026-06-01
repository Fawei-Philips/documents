using Microsoft.Extensions.Configuration;

namespace Utils.Configuration
{
    public static class AppConfig
    {
        public static IConfiguration? Configuration { get; private set; }

        public static void Init()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("Development") ?? "Production"}.json", optional: true)
                .AddEnvironmentVariables();

            Configuration = builder.Build();
        }
    }
}
