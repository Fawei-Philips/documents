using Asp.Versioning.ApiExplorer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace NetUtils.Aspnet.Configurations.Swagger
{
    public static class SwaggerExtensions
    {

        extension(WebApplicationBuilder builder)
        {
            public void AddSwaggerGenExt(string appDocXml, Action<SwaggerGenOptions>? customize = null)
            {
                builder.ConfigSwaggerVersioning();
                builder.Services.AddSwaggerGen(options =>
                {
                    #region Attach Swagger XML Comments

                    //var xmlFile = $"{typeof(Program).Assembly.GetName().Name}.xml";
                    var xmlPath = Path.Combine(AppContext.BaseDirectory, appDocXml);

                    // Add the XML comments file for Swagger
                    options.IncludeXmlComments(xmlPath, true);
                    options.OrderActionsBy(o => o.RelativePath);

                    customize?.Invoke(options);

                    #endregion Attach Swagger XML Comments
                });
            }

            private void ConfigSwaggerVersioning()
            {
                builder.Services.Configure<ApiInfo>(builder.Configuration.GetSection("ApiInfo"));
                builder.Services.AddEndpointsApiExplorer();
                builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>,
                    ApiVersionOptions>();
                builder.Services.AddSwaggerGen(options =>
                {
                    #region Switch API versions by Asp.Versioning.Mvc

                    //add a custom operation filter to set the default values
                    //options.OperationFilter<SwaggerDefaultValues>(); TODO
                    options.DescribeAllParametersInCamelCase();
                    options.OperationFilter<VersionControlParameter>();

                    #endregion Switch API versions by Asp.Versioning.Mvc
                });
                builder.Services.Configure<RouteOptions>(options =>
                {
                    options.LowercaseUrls = true;
                    options.LowercaseQueryStrings = true;
                });
            }
        }

        extension(WebApplication app)
        {
            public void UseSwaggerExt()
            {
                app.UseSwagger();
                app.UseSwaggerUI(options =>
                {
                    var provider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();

                    foreach (var description in provider.ApiVersionDescriptions.Reverse())
                    {
                        var versionName = $"{app.Environment.ApplicationName} {description.GroupName.ToUpperInvariant()}";
                        options.SwaggerEndpoint($"/swagger/{description.GroupName}/swagger.json",
                            versionName);
                    }
                });
            }
        }
    }
}
