using Asp.Versioning;
using Asp.Versioning.ApiExplorer;
using Microsoft.Extensions.Options;
using System.Text;
using Swashbuckle.AspNetCore.SwaggerGen;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi;

namespace NetUtils.Aspnet.Configurations.Swagger
{
    public class ApiVersionOptions : IConfigureOptions<SwaggerGenOptions>
    {

        private readonly IApiVersionDescriptionProvider _provider;
        private readonly ApiInfo _apiInfo;

        public ApiVersionOptions(IApiVersionDescriptionProvider provider, IOptions<ApiInfo> openApiInfo)
        {
            _provider = provider;
            _apiInfo = openApiInfo.Value;
        }

        /// <summary>
        /// Used to configure Swagger options with API versioning support.
        /// </summary>
        /// <param name="options"></param>
        public void Configure(SwaggerGenOptions options)
        {
            // add a swagger document for each discovered API version
            foreach (var description in _provider.ApiVersionDescriptions)
            {
                options.SwaggerDoc(description.GroupName, CreateInfoForApiVersion(description));
            }
        }

        private OpenApiInfo CreateInfoForApiVersion(ApiVersionDescription description)
        {
            var text = new StringBuilder(_apiInfo.Title);
            //var info = new OpenApiInfo()
            //{
            //    Title = "WebApi service for studying",
            //    Version = description.ApiVersion.ToString(),
            //    Contact = new OpenApiContact()
            //    {
            //        Name = "Fawei",
            //        Email = "perfect200@163.com",
            //    }
            //};

            var info = new OpenApiInfo()
            {
                Title = _apiInfo.Title,
                Version = description.ApiVersion.ToString(),
                Contact = new OpenApiContact()
                {
                    Name = _apiInfo.ContactName,
                    Email = _apiInfo.ContactEmail,
                }
            };

            if (description.IsDeprecated)
            {
                text.Append("This API version has been deprecated. ");
            }

            /*
             * 主要用途
                •	告知客户端 某个 API 版本将在指定日期后不再受支持。
                •	自动在响应头中添加 Sunset 信息，如 Sunset、Link（指向迁移文档或公告）等。
                •	配合 API 文档（如 Swagger）显示废弃和下线信息。
                主要属性
                •	Date：API 版本的下线日期（DateTimeOffset?）。
                •	Links：相关的迁移或公告链接（IReadOnlyList<LinkHeaderValue>）。
                •	Policy：自定义的通知内容或策略说明。
             */
            if (description.SunsetPolicy is SunsetPolicy policy)
            {
                if (policy.Date is DateTimeOffset when)
                {
                    text.Append($"This API version will be sunset on");
                    text.Append(when.Date.ToShortDateString());
                    text.Append(".");
                }

                if (policy.HasLinks)
                {
                    text.Append(" For more information, see ");
                    foreach (var link in policy.Links)
                    {
                        if ("text/html".Equals(link.Type.Value, StringComparison.OrdinalIgnoreCase))
                        {
                            text.AppendLine();
                            if (link.Title.HasValue)
                            {
                                text.Append(link.Title.Value).Append(": ");
                            }

                            text.Append(link.LinkTarget.OriginalString);
                        }
                    }
                }
            }

            info.Description = text.ToString();
            return info;
        }
    }
}
