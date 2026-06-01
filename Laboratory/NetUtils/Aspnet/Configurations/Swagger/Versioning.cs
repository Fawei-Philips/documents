using Asp.Versioning;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace NetUtils.Aspnet.Configurations.Swagger
{
    public static class Versioning
    {
        public static void ConfigApiVersion(this WebApplicationBuilder builder)
        {
            // Add API versioning
            builder.Services.AddApiVersioning(options =>
            {
                options.ReportApiVersions = true; // Include API version in response headers
                options.AssumeDefaultVersionWhenUnspecified = true; // Use default version if not specified
                options.DefaultApiVersion = new ApiVersion(1, 0); // Set default API version
                options.ApiVersionReader = new HeaderApiVersionReader("api-version"); // Read version from request header
                options.ApiVersionSelector = new CurrentImplementationApiVersionSelector(options); // Select current API version
            }).AddMvc()
            .AddApiExplorer(options =>
            {
                options.GroupNameFormat = "'v'VVV"; // Format for versioned API groups
            });
        }
    }
}
