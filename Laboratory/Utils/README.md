# Provide utilities for C#

## Configurations

### AppConfig

- Supprot app level configuration. Similar as appsettings.json in .net core

### IOCConfig

- Support IOC / DI configuration by assembly scanning
- Support attribute based registration

### Tasking

- Support safe fire and forget task execution with exception handling

## EncodingEx

### HashHelper.cs

- Support hash algorithms: MD5, SHA256

## Enumerable

### DictionaryExt.cs

- Support AddOrUpdate for Dictionary
- Support HasItem for Dictionary
- Support ToJson for Dictionary

## Json Serialization

- Support camelCase for Json Serialization based on System.Text.Json

```csharp
JsonSerializerUtil.SerializeCamelCase<TValue>(TValue value);
```
