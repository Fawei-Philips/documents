using Logging;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace NetUtils.Repository.Configurations
{
    public static class DbContextRegister
    {
        public static void AddSqlServerContext<TContext>(this WebApplicationBuilder builder, string? configPath) where TContext : DbContext
        {
            if (string.IsNullOrEmpty(configPath))
            {
                Log4Logger.Logger.Error($"DbConnectionString is empty.");
                throw new ArgumentNullException($"DbConnectionString is empty.");
            }

            builder.Services.AddDbContext<TContext>(options =>
            {
                //Data Source=DESKTOP-XICHENG\FAWEISQLEXPRESS;Initial Catalog=master;Integrated Security=True;Trust Server Certificate=True
                options.UseSqlServer(builder.Configuration.GetConnectionString(configPath));
            });
        }
    }
}
