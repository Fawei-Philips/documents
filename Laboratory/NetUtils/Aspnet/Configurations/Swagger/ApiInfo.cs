namespace NetUtils.Aspnet.Configurations.Swagger
{
    public record ApiInfo
    {
        public required string Title { get; init; }
        public required string ContactName { get; init; }
        public required string ContactEmail { get; init; }
    }
}
