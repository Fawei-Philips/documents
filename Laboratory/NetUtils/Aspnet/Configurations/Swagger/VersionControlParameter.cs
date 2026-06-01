using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace NetUtils.Aspnet.Configurations.Swagger
{
    public class VersionControlParameter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            if (operation?.Parameters == null)
            {
                throw new ArgumentNullException(nameof(operation));
            }
            var versionParameter = operation.Parameters
                .FirstOrDefault(p => p.Name == "api-version");
            if (versionParameter == null)
            {
                return;
            }

            // Remove the version parameter from the operation
            operation.Parameters.Remove(versionParameter);
        }
    }
}
