namespace NetUtils.Aspnet.Repository
{
    public interface ISoftDelete
    {
        bool IsDeleted { get; }

        void MarkAsDeleted();
    }
}
