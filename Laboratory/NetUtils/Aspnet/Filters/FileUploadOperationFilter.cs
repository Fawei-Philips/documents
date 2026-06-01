using Microsoft.AspNetCore.Http;
using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace NetUtils.Aspnet.Filters
{
    public class FileUploadOperationFilter : IOperationAsyncFilter
    {
        private const string MediaTypeMultipartFormData = "multipart/form-data";
        private const string SchemaFormatBinary = "binary";
        private const string PropertyNameFile = "file";

        public async Task ApplyAsync(OpenApiOperation operation, OperationFilterContext context, CancellationToken cancellationToken)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var hasFileParameter = await ValueTask.FromResult(
                context.MethodInfo.GetParameters()
                    .Any(p => p.ParameterType == typeof(IFormFile) || p.ParameterType == typeof(IFormFileCollection))
            );

            if (!hasFileParameter)
            {
                return;
            }

            operation.RequestBody = new OpenApiRequestBody
            {
                Content = new Dictionary<string, OpenApiMediaType>
                {
                    [MediaTypeMultipartFormData] = new OpenApiMediaType
                    {
                        Schema = new OpenApiSchema
                        {
                            Type = JsonSchemaType.Object,
                            Properties = new Dictionary<string, IOpenApiSchema>
                            {
                                [PropertyNameFile] = new OpenApiSchema
                                {
                                    Type = JsonSchemaType.String,
                                    Format = SchemaFormatBinary,
                                    Description = "File to upload"
                                },
                                ["description"] = new OpenApiSchema
                                {
                                    Type = JsonSchemaType.String,
                                    Description = "File description(optional)",
                                    Default = string.Empty
                                }
                            },
                            Required = new HashSet<string> { PropertyNameFile }
                        }
                    }
                },
                Required = true
            };
        }
    }
}
