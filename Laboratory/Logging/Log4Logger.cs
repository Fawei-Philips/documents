using log4net;
using log4net.Config;
namespace Logging
{
    public static class Log4Logger
    {
        #region Properties

        public static ILog Logger { get { return GetLogger(); } }

        private static ILog? _logger;

        #endregion Properties

        #region Init

        static Log4Logger()
        {
            InitLogger();
        }

        private static void InitLogger()
        {
            GlobalContext.Properties["logDir"] = GlobalContext.Properties["logDir"] ?? "logs";
            XmlConfigurator.Configure();
            _logger = LogManager.GetLogger(GetLoggerType(typeof(Log4Logger)));
        }

        private static Type GetLoggerType(Type? type)
        {
            if (type == null)
            {
                return typeof(Log4Logger);
            }

            return type;
        }

        #endregion Init

        #region Public

        public static ILog GetLogger()
        {
            if (_logger != null)
            {
                return _logger;
            }
            _logger = LogManager.GetLogger(GetLoggerType(null));

            return _logger;

        }
        #endregion Public
    }
}
