using log4net;
using Microsoft.Extensions.Logging;

namespace Logging
{
    public static class LoggingConfig
    {
        public static void LoggingSetup(string? path)
        {
            if (string.IsNullOrEmpty(path))
            {
                return;
            }
            GlobalContext.Properties["logDir"] = path;
        }

        public static void NetCoreLoggingSetup(this ILoggingBuilder loggingBuilder, string? logPath)
        {
            LoggingSetup(logPath);
            loggingBuilder.AddLog4Net("log4net.config");
        }
    }
}
