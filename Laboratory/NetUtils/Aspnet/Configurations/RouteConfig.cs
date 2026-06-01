using Microsoft.Extensions.DependencyInjection;

namespace NetUtils.Aspnet.Configurations
{
    public static class RouteConfig
    {
        public static IServiceCollection ConfigureRoutes(this IServiceCollection services)
        {
            services.AddRouting(options =>
            {
                options.LowercaseUrls = true;
                options.LowercaseQueryStrings = true;
                options.AppendTrailingSlash = false;
            });
            return services;
        }
    }
}
