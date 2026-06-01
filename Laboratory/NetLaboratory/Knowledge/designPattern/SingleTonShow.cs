namespace NetLaboratory.Knowledge.designPattern
{
    #region Recommended Way

    // 1. Use IOC
    // 2. Use staitc constructor


    public sealed class Singleton
    {
        public static readonly Singleton Instance;

        // 静态构造方法（自动线程安全）
        static Singleton()
        {
            Instance = new Singleton();
        }

        // 私有构造函数，防止外部实例化
        private Singleton() { }
    }

    #endregion Way

    #region New Way

    /*
     * 如果你使用的是 C# 5.0 或更高版本，并且运行在 .NET Framework 4.0 或更高版本上，
     * 可以通过使用 Lazy<T> 来简化单例实现，它会自动处理线程安全问题：
     */

    public sealed class SingleTonShow
    {
        private static readonly Lazy<SingleTonShow> lazy =
            new Lazy<SingleTonShow>(() => new SingleTonShow());

        public static SingleTonShow Instance { get { return lazy.Value; } }

        private SingleTonShow() { }
    }

    #endregion New Way
    #region Old Way
    internal class SingleTonShow03
    {
        private static volatile SingleTonShow03? _instance;
        private static readonly object _lock = new object();
        private SingleTonShow03()
        {
            // 私有构造函数，防止外部实例化
        }

        public static SingleTonShow03 GetInstance()
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = new SingleTonShow03();
                    }
                }
            }
            return _instance;
        }
    }

    #endregion Old Way
}
