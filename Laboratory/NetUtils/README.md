# .net10 webapi utils

## Program.cs will be like this

```CSharp
using Logging;
using NetUtils.Aspnet.Configurations;
using NetUtils.Aspnet.Configurations.Swagger;
using NetUtils.Aspnet.Filters;
using service.file.Configurations.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.NetCoreLoggingSetup(Path.Combine("logs", builder.Environment.ApplicationName));
builder.Services.AddControllers();

builder.ConfigApiVersion();

// Add services to the container.
builder.RegisterCommonServices();
builder.RegisterServices();
builder.Services.AllowCorsExt();
builder.AddSwaggerGenExt($"{typeof(Program).Assembly.GetName().Name}.xml", swaggerGenOptions =>
{
    // support file button in swagger
    swaggerGenOptions.OperationAsyncFilter<FileUploadOperationFilter>();
});

var app = builder.Build();

app.ConfigApp();

app.Run();

```

## Add ServiceRegister.cs to your project

```Csharp
using NetUtils.Aspnet.Configurations;
using repository.doraemon.Repositories;
using service.file.Configurations.DomainSettings;

namespace service.file.Configurations.Services
{
    public static class ServicesRegister
    {
        extension(WebApplicationBuilder builder)
        {
            public void RegisterServices()
            {
                builder.RegisterAssembliesAutofac(
                [
                    typeof(Program).Assembly,
                    typeof(IFileRepository).Assembly // your repository assemblies
                ]);
                builder.RegisterMiddlewares();
                builder.Configurations();
            }

            private void RegisterMiddlewares()
            {
                // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
                builder.Services.AddOpenApi();
            }

            private void Configurations()
            {
                // build your customized configs under appsettings.json
                builder.Services.Configure<FileStorageSettings>(builder.Configuration.GetSection(Constants.FileStorageSettings));
            }
        }
    }
}

```

## packages used

### C# Utils nuget package

[net.Utils.perfect2645](https://github.com/perfect2645/Laboratory/tree/main/Utils)

### Api Versioning

[ApiVersioning](https://github.com/dotnet/aspnet-api-versioning)

### Swashbuckle.AspNetCore.SwaggerGen

## Internal functions

### NetCore configurations

- IOC / DI configuration
- Api Versioning configuration
- Swagger configuration
- CORS configuration

```json
// appsettings.json
  "Cors": {
    "PolicyName": "SignalRReactCors",
    "AllowedOrigins": [
      "https://localhost:3000",
      "http://localhost:5173" // vite dev
    ]
  },
```

- WebApplication configuration
- Optimized Json serializer configuration

### Filters

#### GlobalExceptionFilter

The `GlobalExceptionFilter` is an ASP.NET Core filter that handles exceptions globally across the application.
It captures unhandled exceptions thrown during the execution of controller actions and processes them in a centralized manner.

#### FileUploadOperationFilter

Supports file upload in Swagger UI.

```
// program.cs
builder.AddSwaggerGenExt($"{typeof(Program).Assembly.GetName().Name}.xml", swaggerGenOptions =>
{
    // support file button in swagger
    swaggerGenOptions.OperationAsyncFilter<FileUploadOperationFilter>();
});
```

## Entity Framework Core

### Sql Server Database support

- AddSqlServerContext

```CSharp
var builder = WebApplication.CreateBuilder(args);

// your configuration
builder.AddSqlServerContext<ShirtsDbContext>("Net10DemoDb");
// your configuration
```

- Use repository pattern

```CSharp
    public interface IShirtRepository : IRepository<Shirt, int>
    {
        Task<Shirt?> GetByPropertiesAsync(string brand, string gender, string color, int size);
    }

    [Register(ServiceType = typeof(IShirtRepository), Lifetime = Lifetime.Scoped)]
    public class ShirtRepository : RepositoryBase<Shirt, int>, IShirtRepository
    {
        private readonly ShirtsDbContext _dbContext;
        public ShirtRepository(ShirtsDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext;
        }

        public Task<Shirt?> GetByPropertiesAsync(string brand, string gender, string color, int size)
        {
            var targetShirt = DbSet.FirstOrDefaultAsync(s =>
                s.Brand.Equals(brand, StringComparison.OrdinalIgnoreCase)
                && s.Gender.Equals(gender, StringComparison.OrdinalIgnoreCase)
                && s.Color.Equals(color, StringComparison.OrdinalIgnoreCase)
                && s.Size == size);

            return targetShirt;
        }
    }
```
