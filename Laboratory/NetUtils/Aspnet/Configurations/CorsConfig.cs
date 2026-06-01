using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace NetUtils.Aspnet.Configurations
{
    public static class CorsConfig
    {
        extension(IServiceCollection services)
        {
            public void AllowCorsExt()
            {
                var serviceProvider = services.BuildServiceProvider();
                var configuration = serviceProvider.GetRequiredService<IConfiguration>();

                if (!configuration.GetSection("Cors").Exists())
                {
                    return;
                }

                var policyName = configuration["Cors:PolicyName"];
                var allowedOrigins = configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();

                if (string.IsNullOrWhiteSpace(policyName))
                {
                    throw new InvalidOperationException("CORS config error: policyName cannot be empty, please check your appsettings.json");
                }

                if (allowedOrigins == null || allowedOrigins.Length == 0 || allowedOrigins.All(string.IsNullOrWhiteSpace))
                {
                    throw new ArgumentException("Cors origins can not be empty", nameof(allowedOrigins));
                }

                services.AddCors(options =>
                {
                    options.AddPolicy(policyName, policy =>
                    {
                        // white list
                        policy.WithOrigins(allowedOrigins)
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials(); // Must for SignalR 
                    });
                });
            }
        }

        extension(IApplicationBuilder app)
        {
            public void UseCorsExt()
            {
                var configuration = app.ApplicationServices.GetRequiredService<IConfiguration>();
                if (!configuration.GetSection("Cors").Exists())
                {
                    return;
                }

                var policyName = configuration["Cors:PolicyName"];
                if (string.IsNullOrWhiteSpace(policyName))
                {
                    throw new InvalidOperationException("CORS config error: policyName cannot be empty, please check your appsettings.json");
                }

                app.UseCors(policyName);
            }
        }
    }
}
