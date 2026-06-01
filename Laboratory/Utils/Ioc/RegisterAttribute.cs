namespace Utils.Ioc
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class RegisterAttribute : Attribute
    {
        public Lifetime Lifetime { get; set; } = Lifetime.Transient;
        public Type? ServiceType { get; set; }
        public string? Key { get; set; }
    }

    public enum Lifetime
    {
        Singleton,
        Scoped,
        Transient
    }
}
