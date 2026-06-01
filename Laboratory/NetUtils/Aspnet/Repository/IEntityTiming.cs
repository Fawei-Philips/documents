namespace NetUtils.Aspnet.Repository
{
    public interface IEntityTiming
    {
        public DateTime CreateTime { get; }
        public DateTime? UpdateTime { get; }
    }
}
