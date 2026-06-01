# Common Logging Library
## A versatile logging library for .NET applications.

## Log4net in Webapi

```
// specify log output path (default - app base dir / logs)
builder.Logging.NetCoreLoggingSetup(Path.Combine("logs", builder.Environment.ApplicationName));
```