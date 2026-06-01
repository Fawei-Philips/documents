
using Autofac;
using System.Reflection;
using Utils.Enumerable;

namespace Utils.Ioc
{
    public class AutoRegisterModule : Autofac.Module
    {
        private readonly Assembly[] _assemblies;

        public AutoRegisterModule(params Assembly[] assemblies)
        {
            _assemblies = assemblies ?? throw new ArgumentNullException(
                nameof(assemblies), "One or more assemblies required.");
        }
        protected override void Load(ContainerBuilder builder)
        {
            var targetTypes = _assemblies.SelectMany(assembly => assembly.GetTypes())
                .Where(type =>
                    type.IsClass &&
                    !type.IsAbstract &&
                    type.GetCustomAttribute<RegisterAttribute>() != null)
                .ToList();

            if (!targetTypes.HasItem())
            {
                return;
            }

            foreach (var type in targetTypes)
            {
                var attribute = type.GetCustomAttribute<RegisterAttribute>()!;
                RegisterForOneClass(builder, type, attribute);
            }
        }

        private void RegisterForOneClass(ContainerBuilder builder, Type implementationType, RegisterAttribute attribute)
        {
            var serviceType = attribute.ServiceType ?? GetServiceType(implementationType);
            var registration = builder.RegisterType(implementationType).As(serviceType);
            var key = attribute.Key;

            switch (attribute.Lifetime)
            {
                case Lifetime.Singleton:
                    if (string.IsNullOrEmpty(key))
                    {
                        registration.SingleInstance();
                    }
                    else
                    {
                        registration.Keyed(key, serviceType).SingleInstance();
                    }
                    break;
                case Lifetime.Scoped:
                    if (string.IsNullOrEmpty(key))
                    {
                        registration.InstancePerLifetimeScope();
                    }
                    else
                    {
                        registration.Keyed(key, serviceType).InstancePerLifetimeScope();
                    }
                    break;
                case Lifetime.Transient:
                default:
                    if (string.IsNullOrEmpty(key))
                    {
                        registration.InstancePerDependency();
                    }
                    else
                    {
                        registration.Keyed(key, serviceType).InstancePerDependency();
                    }
                    break;
            }
        }

        private Type GetServiceType(Type implementationType)
        {
            var interfaces = implementationType.GetInterfaces();
            if (interfaces.Length == 0)
            {
                return implementationType;
            }

            var matchedInterface = interfaces.FirstOrDefault(
                i => i.Name.Equals($"I{implementationType.Name}", StringComparison.Ordinal));

            return matchedInterface ?? interfaces.First();
        }
    }
}
